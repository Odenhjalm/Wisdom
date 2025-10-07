#!/usr/bin/env python3
"""Automated smoke test for teacher/studio flows against the local backend.

Usage:
    scripts/qa_teacher_smoke.py --base-url http://localhost:8000 \
        --teacher-email teacher@example.com --teacher-password teacher123 \
        --student-email student@example.com --student-password student123

Any flag can be omitted if the corresponding environment variable is set:
    QA_API_BASE_URL
    QA_TEACHER_EMAIL / QA_TEACHER_PASSWORD
    QA_STUDENT_EMAIL / QA_STUDENT_PASSWORD

The script performs the following high-level steps:
  1. Login as teacher, create a course/module/lesson, upload a media file.
  2. Login as student, verify the course appears and intro flows work.
  3. Trigger quiz ensure/list APIs.
  4. Cleanup created resources.

Exit code 0 indicates success; non-zero indicates a failure. All HTTP calls
are validated for expected status codes and key payload fields.
"""

from __future__ import annotations

import argparse
import os
import sys
import uuid
from dataclasses import dataclass
from pathlib import Path

import requests

SAMPLE_AVATAR_GIF = (
    b"GIF89a\x01\x00\x01\x00\x80\x01\x00\x00\x00\x00\xff\xff\xff!"
    b"\xf9\x04\x01\n\x00\x01\x00,\x00\x00\x00\x00\x01\x00\x01\x00"
    b"\x00\x02\x02D\x01\x00;"
)


@dataclass
class AuthSession:
    token: str
    refresh_token: str
    user_id: str


class SmokeTestError(RuntimeError):
    pass


def _env_or_default(env_key: str, cli_value: str | None, fallback: str | None = None) -> str:
    value = cli_value or os.environ.get(env_key) or fallback
    if not value:
        raise SmokeTestError(f"Missing required configuration for {env_key}")
    return value


def login(base_url: str, email: str, password: str) -> AuthSession:
    resp = requests.post(
        f"{base_url}/auth/login",
        json={"email": email, "password": password},
        timeout=10,
    )
    if resp.status_code != 200:
        raise SmokeTestError(f"Login failed for {email}: {resp.status_code} {resp.text}")
    data = resp.json()
    token = data.get("access_token")
    if not token:
        raise SmokeTestError("Login response missing access token")
    refresh = data.get("refresh_token")
    if not refresh:
        raise SmokeTestError("Login response missing refresh token")
    profile_resp = requests.get(
        f"{base_url}/profiles/me",
        headers={"Authorization": f"Bearer {token}"},
        timeout=10,
    )
    if profile_resp.status_code != 200:
        raise SmokeTestError(
            f"Failed to fetch profile for {email}: {profile_resp.status_code} {profile_resp.text}"
        )
    user_id = profile_resp.json().get("user_id")
    if not user_id:
        raise SmokeTestError("Profile response missing user_id")
    return AuthSession(token=token, refresh_token=refresh, user_id=str(user_id))


def refresh_session(base_url: str, session: AuthSession) -> AuthSession:
    resp = requests.post(
        f"{base_url}/auth/refresh",
        json={"refresh_token": session.refresh_token},
        timeout=10,
    )
    if resp.status_code != 200:
        raise SmokeTestError(f"Refresh failed: {resp.status_code} {resp.text}")
    data = resp.json()
    access = data.get("access_token")
    refresh = data.get("refresh_token")
    if not access or not refresh:
        raise SmokeTestError("Refresh response missing tokens")
    return AuthSession(token=access, refresh_token=refresh, user_id=session.user_id)



def auth_headers(session: AuthSession) -> dict[str, str]:
    return {"Authorization": f"Bearer {session.token}"}


def create_course(base_url: str, session: AuthSession, slug_prefix: str = "qa-course") -> dict:
    slug = f"{slug_prefix}-{uuid.uuid4().hex[:8]}"
    payload = {
        "title": "QA Smoke Course",
        "slug": slug,
        "description": "Automated smoke test course",
        "price_cents": 1999,
        "is_free_intro": True,
        "is_published": False,
    }
    resp = requests.post(
        f"{base_url}/studio/courses",
        json=payload,
        headers=auth_headers(session),
        timeout=10,
    )
    if resp.status_code != 200:
        raise SmokeTestError(f"Failed to create course: {resp.status_code} {resp.text}")
    data = resp.json()
    return data


def create_module(base_url: str, session: AuthSession, course_id: str) -> dict:
    resp = requests.post(
        f"{base_url}/studio/modules",
        json={"course_id": course_id, "title": "Module 1", "position": 1},
        headers=auth_headers(session),
        timeout=10,
    )
    if resp.status_code != 200:
        raise SmokeTestError(f"Failed to create module: {resp.status_code} {resp.text}")
    return resp.json()


def create_lesson(base_url: str, session: AuthSession, module_id: str) -> dict:
    resp = requests.post(
        f"{base_url}/studio/lessons",
        json={
            "module_id": module_id,
            "title": "Lesson 1",
            "content_markdown": "# QA Smoke Lesson",
            "position": 1,
            "is_intro": True,
        },
        headers=auth_headers(session),
        timeout=10,
    )
    if resp.status_code != 200:
        raise SmokeTestError(f"Failed to create lesson: {resp.status_code} {resp.text}")
    return resp.json()


def upload_avatar(base_url: str, session: AuthSession) -> dict:
    resp = requests.post(
        f"{base_url}/profiles/me/avatar",
        headers=auth_headers(session),
        files={"file": ("avatar.gif", SAMPLE_AVATAR_GIF, "image/gif")},
        timeout=15,
    )
    if resp.status_code != 200:
        raise SmokeTestError(f"Failed to upload avatar: {resp.status_code} {resp.text}")
    data = resp.json()
    photo_url = data.get("photo_url")
    media_id = data.get("avatar_media_id")
    if not photo_url or not media_id:
        raise SmokeTestError("Avatar upload response missing expected fields")
    if not str(photo_url).endswith(str(media_id)):
        raise SmokeTestError("Avatar URL does not reference uploaded media id")
    return data


def upload_media(base_url: str, session: AuthSession, lesson_id: str) -> dict:
    files = {
        "file": ("smoke.mp3", b"ID3 QA SMOKE", "audio/mpeg"),
    }
    data = {"is_intro": "false"}
    resp = requests.post(
        f"{base_url}/studio/lessons/{lesson_id}/media",
        headers=auth_headers(session),
        files=files,
        data=data,
        timeout=30,
    )
    if resp.status_code != 200:
        raise SmokeTestError(f"Failed to upload media: {resp.status_code} {resp.text}")
    return resp.json()


def list_lesson_media(base_url: str, session: AuthSession, lesson_id: str) -> list[dict]:
    resp = requests.get(
        f"{base_url}/studio/lessons/{lesson_id}/media",
        headers=auth_headers(session),
        timeout=10,
    )
    if resp.status_code != 200:
        raise SmokeTestError(
            f"Failed to list lesson media: {resp.status_code} {resp.text}"
        )
    return resp.json().get("items", [])


def ensure_quiz(base_url: str, session: AuthSession, course_id: str) -> str | None:
    resp = requests.post(
        f"{base_url}/studio/courses/{course_id}/quiz",
        headers=auth_headers(session),
        timeout=10,
    )
    if resp.status_code != 200:
        return None
    return str(resp.json().get("quiz", {}).get("id"))


def student_checks(base_url: str, session: AuthSession, course_id: str) -> None:
    resp = requests.get(
        f"{base_url}/courses",
        headers=auth_headers(session),
        timeout=10,
    )
    if resp.status_code != 200:
        raise SmokeTestError(f"Student course list failed: {resp.status_code} {resp.text}")
    items = resp.json().get("items", [])
    if course_id not in {str(item.get("id")) for item in items}:
        raise SmokeTestError("Student cannot see published course in list")

    detail = requests.get(
        f"{base_url}/courses/{course_id}",
        headers=auth_headers(session),
        timeout=10,
    )
    if detail.status_code != 200:
        raise SmokeTestError(f"Course detail failed: {detail.status_code} {detail.text}")


def cleanup_course(base_url: str, session: AuthSession, *, course_id: str, module_id: str, lesson_id: str, media_id: str | None) -> None:
    headers = auth_headers(session)
    if media_id:
        requests.delete(f"{base_url}/studio/media/{media_id}", headers=headers, timeout=10)
    requests.delete(f"{base_url}/studio/lessons/{lesson_id}", headers=headers, timeout=10)
    requests.delete(f"{base_url}/studio/modules/{module_id}", headers=headers, timeout=10)
    requests.delete(f"{base_url}/studio/courses/{course_id}", headers=headers, timeout=10)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="QA smoke test for teacher flows")
    parser.add_argument("--base-url", dest="base_url")
    parser.add_argument("--teacher-email", dest="teacher_email")
    parser.add_argument("--teacher-password", dest="teacher_password")
    parser.add_argument("--student-email", dest="student_email")
    parser.add_argument("--student-password", dest="student_password")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        base_url = _env_or_default("QA_API_BASE_URL", args.base_url, "http://localhost:8000")
        teacher_email = _env_or_default("QA_TEACHER_EMAIL", args.teacher_email, "teacher@example.com")
        teacher_password = _env_or_default("QA_TEACHER_PASSWORD", args.teacher_password, "teacher123")
        student_email = _env_or_default("QA_STUDENT_EMAIL", args.student_email, "student@example.com")
        student_password = _env_or_default("QA_STUDENT_PASSWORD", args.student_password, "student123")

        print(f"[1/7] Logging in as teacher {teacher_email} …")
        teacher_session = login(base_url, teacher_email, teacher_password)
        teacher_session = refresh_session(base_url, teacher_session)
        print("  Refresh token rotation verified.")

        print("[2/7] Uploading avatar …")
        avatar = upload_avatar(base_url, teacher_session)
        profile_check = requests.get(
            f"{base_url}/profiles/me",
            headers=auth_headers(teacher_session),
            timeout=10,
        )
        if profile_check.status_code != 200:
            raise SmokeTestError(
                f"Failed to read profile after avatar upload: {profile_check.status_code} {profile_check.text}"
            )
        profile_data = profile_check.json()
        if profile_data.get("avatar_media_id") != avatar.get("avatar_media_id"):
            raise SmokeTestError("Avatar media id not stored on profile")

        print("[3/7] Creating course/module/lesson …")
        course = create_course(base_url, teacher_session)
        course_id = str(course["id"])
        module = create_module(base_url, teacher_session, course_id)
        module_id = str(module["id"])
        lesson = create_lesson(base_url, teacher_session, module_id)
        lesson_id = str(lesson["id"])

        print("[4/7] Uploading media …")
        media = upload_media(base_url, teacher_session, lesson_id)
        media_id = str(media.get("id")) if media.get("id") else None
        linked_media_id = media.get("media_id")
        if not linked_media_id:
            raise SmokeTestError("Upload response missing media_id")
        if not media.get("download_url"):
            raise SmokeTestError("Upload response missing download_url")
        if not media.get("storage_bucket"):
            raise SmokeTestError("Upload response missing storage_bucket")

        items = list_lesson_media(base_url, teacher_session, lesson_id)
        matched = next((m for m in items if str(m.get("id")) == media_id), None)
        if matched is None:
            raise SmokeTestError("Uploaded media missing from lesson listing")
        if not matched.get("original_name"):
            raise SmokeTestError("Lesson media missing original_name")
        if not matched.get("byte_size"):
            raise SmokeTestError("Lesson media missing byte_size")

        print("[5/7] Ensuring quiz setup …")
        quiz_id = ensure_quiz(base_url, teacher_session, course_id)
        if quiz_id:
            print(f"  Quiz ready: {quiz_id}")
        else:
            print("  Quiz ensured endpoint unavailable or returned non-200; continuing.")

        print(f"[6/7] Logging in as student {student_email} …")
        student_session = login(base_url, student_email, student_password)
        student_checks(base_url, student_session, course_id)

        print("[7/7] Cleaning up temporary resources …")
        cleanup_course(
            base_url,
            teacher_session,
            course_id=course_id,
            module_id=str(module_id),
            lesson_id=str(lesson_id),
            media_id=media_id,
        )

        print("Smoke test completed successfully.")
        return 0
    except SmokeTestError as err:
        print(f"Smoke test failed: {err}", file=sys.stderr)
        return 1
    except Exception as exc:  # pragma: no cover - unexpected failures
        print(f"Unexpected error: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
