import hashlib
from pathlib import Path
from uuid import uuid4

from fastapi import APIRouter, File, Form, HTTPException, UploadFile
from fastapi.responses import FileResponse

from .. import models, schemas
from ..auth import CurrentUser
from ..config import settings
from ..permissions import TeacherUser

router = APIRouter(prefix="/studio", tags=["studio"])

def _detect_kind(content_type: str | None) -> str:
    if not content_type:
        return "other"
    lower = content_type.lower()
    if lower.startswith("image/"):
        return "image"
    if lower.startswith("video/"):
        return "video"
    if lower.startswith("audio/"):
        return "audio"
    if lower == "application/pdf":
        return "pdf"
    return "other"


_ALLOWED_MEDIA_PREFIXES = ("image/", "video/", "audio/")
_ALLOWED_MEDIA_TYPES = {"application/pdf"}
_MAX_MEDIA_BYTES = 25 * 1024 * 1024  # 25 MB
_LESSON_MEDIA_BUCKET = "lesson-media"


@router.get("/courses")
async def studio_courses(current: TeacherUser):
    rows = await models.teacher_courses(current["id"])
    return {"items": rows}


@router.get("/status")
async def studio_status(current: CurrentUser):
    info = await models.teacher_status(current["id"])
    return info


@router.get("/certificates")
async def studio_certificates(
    current: CurrentUser, verified_only: bool = False
):
    rows = await models.user_certificates(current["id"], verified_only)
    return {"items": rows}


@router.post("/certificates")
async def studio_add_certificate(
    payload: schemas.StudioCertificateCreate,
    current: CurrentUser,
):
    row = await models.add_certificate(
        current["id"],
        title=payload.title,
        status=payload.status,
        notes=payload.notes,
        evidence_url=payload.evidence_url,
    )
    return row


@router.post("/apply")
async def apply_teacher(current: CurrentUser):
    row = await models.upsert_teacher_application(current["id"])
    return row


@router.post("/courses")
async def create_course(payload: schemas.StudioCourseCreate, current: TeacherUser):
    row = await models.create_course_for_user(current["id"], payload.model_dump())
    if not row:
        raise HTTPException(status_code=400, detail="Failed to create course")
    return row


@router.get("/courses/{course_id}")
async def course_meta(course_id: str, current: TeacherUser):
    if not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    row = await models.get_course(course_id=course_id)
    if not row:
        raise HTTPException(status_code=404, detail="Course not found")
    return row


@router.patch("/courses/{course_id}")
async def update_course(
    course_id: str,
    payload: schemas.StudioCourseUpdate,
    current: TeacherUser,
):
    row = await models.update_course_for_user(
        current["id"], course_id, payload.model_dump(exclude_unset=True)
    )
    if not row:
        raise HTTPException(status_code=403, detail="Not course owner")
    return row


@router.delete("/courses/{course_id}")
async def delete_course(course_id: str, current: TeacherUser):
    deleted = await models.delete_course_for_user(current["id"], course_id)
    if not deleted:
        raise HTTPException(status_code=403, detail="Not course owner")
    return {"deleted": True}


@router.get("/courses/{course_id}/modules")
async def course_modules(course_id: str, current: TeacherUser):
    if not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    modules = list(await models.list_modules(course_id))
    for module in modules:
        lessons = list(await models.list_lessons(module["id"]))
        for lesson in lessons:
            media = list(await models.list_lesson_media(lesson["id"]))
            for item in media:
                item["download_url"] = f"/studio/media/{item['id']}"
            lesson["media"] = media
        module["lessons"] = lessons
    return {"items": modules}


@router.get("/modules/{module_id}/lessons")
async def module_lessons(module_id: str, current: TeacherUser):
    course_id = await models.module_course_id(module_id)
    if not course_id or not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    lessons = list(await models.list_lessons(module_id))
    for lesson in lessons:
        media = list(await models.list_lesson_media(lesson["id"]))
        for item in media:
            item["download_url"] = f"/studio/media/{item['id']}"
        lesson["media"] = media
    return {"items": lessons}


@router.post("/modules")
async def create_module(
    payload: schemas.StudioModuleCreate,
    current: TeacherUser,
):
    if not await models.is_course_owner(current["id"], payload.course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    row = await models.add_module(payload.course_id, payload.title, payload.position)
    if not row:
        raise HTTPException(status_code=400, detail="Failed to create module")
    return row


@router.patch("/modules/{module_id}")
async def update_module(
    module_id: str,
    payload: schemas.StudioModuleUpdate,
    current: TeacherUser,
):
    course_id = await models.module_course_id(module_id)
    if not course_id or not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    row = await models.update_module(module_id, payload.model_dump(exclude_unset=True))
    if not row:
        raise HTTPException(status_code=404, detail="Module not found")
    return row


@router.delete("/modules/{module_id}")
async def delete_module(module_id: str, current: TeacherUser):
    course_id = await models.module_course_id(module_id)
    if not course_id or not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    deleted = await models.delete_module(module_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Module not found")
    return {"deleted": True}


@router.post("/lessons")
async def create_lesson(
    payload: schemas.StudioLessonCreate,
    current: TeacherUser,
):
    course_id = await models.module_course_id(payload.module_id)
    if not course_id or not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    row = await models.upsert_lesson(
        lesson_id=None,
        module_id=payload.module_id,
        title=payload.title,
        content_markdown=payload.content_markdown,
        position=payload.position,
        is_intro=payload.is_intro,
    )
    if not row:
        raise HTTPException(status_code=400, detail="Failed to create lesson")
    return row


@router.patch("/lessons/{lesson_id}")
async def update_lesson(
    lesson_id: str,
    payload: schemas.StudioLessonUpdate,
    current: TeacherUser,
):
    module_id, course_id = await models.lesson_course_ids(lesson_id)
    if not course_id or not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    existing = await models.get_lesson(lesson_id)
    if not existing or not module_id:
        raise HTTPException(status_code=404, detail="Lesson not found")
    row = await models.upsert_lesson(
        lesson_id=lesson_id,
        module_id=module_id,
        title=payload.title,
        content_markdown=payload.content_markdown,
        position=payload.position,
        is_intro=payload.is_intro,
    )
    if not row:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return row


@router.delete("/lessons/{lesson_id}")
async def delete_lesson(lesson_id: str, current: TeacherUser):
    _, course_id = await models.lesson_course_ids(lesson_id)
    if not course_id or not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    deleted = await models.delete_lesson(lesson_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return {"deleted": True}


@router.patch("/lessons/{lesson_id}/intro")
async def set_intro(lesson_id: str, payload: schemas.LessonIntroUpdate, current: TeacherUser):
    _, course_id = await models.lesson_course_ids(lesson_id)
    if not course_id or not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    row = await models.set_lesson_intro(lesson_id, payload.is_intro)
    if not row:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return row


@router.get("/lessons/{lesson_id}/media")
async def lesson_media(lesson_id: str, current: TeacherUser):
    _, course_id = await models.lesson_course_ids(lesson_id)
    if not course_id or not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    media = list(await models.list_lesson_media(lesson_id))
    for item in media:
        item["download_url"] = f"/studio/media/{item['id']}"
    return {"items": media}


@router.post("/lessons/{lesson_id}/media")
async def upload_media(
    lesson_id: str,
    current: TeacherUser,
    file: UploadFile = File(...),
    is_intro: bool = Form(False),
):
    _, course_id = await models.lesson_course_ids(lesson_id)
    if not course_id or not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")

    course_folder = str(course_id)
    dest_dir = Path(settings.media_root) / course_folder / lesson_id
    dest_dir.mkdir(parents=True, exist_ok=True)
    safe_name = f"{uuid4().hex}_{file.filename or 'media'}"
    relative_path = str(Path(course_folder) / lesson_id / safe_name)
    dest_path = dest_dir / safe_name
    content = await file.read()

    content_type = (file.content_type or "").lower()
    if not any(content_type.startswith(prefix) for prefix in _ALLOWED_MEDIA_PREFIXES) and content_type not in _ALLOWED_MEDIA_TYPES:
        raise HTTPException(status_code=415, detail="Unsupported media type")
    if not content:
        raise HTTPException(status_code=400, detail="File payload is empty")
    if len(content) > _MAX_MEDIA_BYTES:
        raise HTTPException(status_code=413, detail="File too large")

    dest_path.write_bytes(content)

    checksum = hashlib.sha256(content).hexdigest()

    existing_media = list(await models.list_lesson_media(lesson_id))
    position = len(existing_media) + 1
    kind = _detect_kind(file.content_type)
    media_object = await models.create_media_object(
        owner_id=current["id"],
        storage_path=relative_path,
        storage_bucket=_LESSON_MEDIA_BUCKET,
        content_type=file.content_type,
        byte_size=len(content),
        checksum=checksum,
        original_name=file.filename,
    )
    media_id = media_object["id"] if media_object else None
    row = await models.add_lesson_media_entry(
        lesson_id=lesson_id,
        kind=kind,
        storage_path=relative_path,
        storage_bucket=_LESSON_MEDIA_BUCKET,
        position=position,
        media_id=media_id,
    )
    if not row:
        raise HTTPException(status_code=400, detail="Failed to save media")
    row["download_url"] = f"/studio/media/{row['id']}"
    return row


@router.delete("/media/{media_id}")
async def delete_media(media_id: str, current: TeacherUser):
    row = await models.get_media(media_id)
    if not row:
        raise HTTPException(status_code=404, detail="Media not found")
    _, course_id = await models.lesson_course_ids(row.get("lesson_id"))
    if course_id and not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    deleted_row = await models.delete_lesson_media_entry(media_id)
    storage_path = deleted_row.get("storage_path") if deleted_row else row.get("storage_path")
    storage_bucket = deleted_row.get("storage_bucket") if deleted_row else row.get("storage_bucket")
    if storage_path:
        candidates = []
        if storage_bucket:
            candidates.append(Path(settings.media_root) / storage_bucket / storage_path)
        candidates.append(Path(settings.media_root) / storage_path)
        for candidate in candidates:
            if candidate.exists():
                candidate.unlink()
    return {"deleted": True}


@router.patch("/lessons/{lesson_id}/media/reorder")
async def reorder_media(
    lesson_id: str,
    payload: schemas.MediaReorder,
    current: TeacherUser,
):
    _, course_id = await models.lesson_course_ids(lesson_id)
    if not course_id or not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    await models.reorder_media(lesson_id, payload.media_ids)
    return {"ok": True}


@router.get("/media/{media_id}")
async def media_file(media_id: str, current: CurrentUser | None = None):
    row = await models.get_media(media_id)
    if not row:
        raise HTTPException(status_code=404, detail="Media not found")
    storage_path = row.get("storage_path")
    if not storage_path:
        raise HTTPException(status_code=404, detail="Media not found")
    file_path = Path(settings.media_root) / storage_path
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File missing")
    return FileResponse(file_path)


@router.post("/courses/{course_id}/quiz")
async def ensure_quiz(course_id: str, current: TeacherUser):
    if not await models.is_course_owner(current["id"], course_id):
        raise HTTPException(status_code=403, detail="Not course owner")
    quiz = await models.ensure_quiz_for_user(course_id, current["id"])
    if not quiz:
        raise HTTPException(status_code=400, detail="Failed to ensure quiz")
    return {"quiz": quiz}


@router.get("/quizzes/{quiz_id}/questions")
async def quiz_questions(quiz_id: str, current: TeacherUser):
    if not await models.quiz_belongs_to_user(quiz_id, current["id"]):
        raise HTTPException(status_code=403, detail="Not quiz owner")
    rows = await models.quiz_questions(quiz_id)
    return {"items": rows}


@router.post("/quizzes/{quiz_id}/questions")
async def create_question(
    quiz_id: str,
    payload: schemas.QuizQuestionUpsert,
    current: TeacherUser,
):
    if not await models.quiz_belongs_to_user(quiz_id, current["id"]):
        raise HTTPException(status_code=403, detail="Not quiz owner")
    row = await models.upsert_quiz_question(
        quiz_id,
        payload.model_dump(exclude_unset=True),
    )
    if not row:
        raise HTTPException(status_code=400, detail="Failed to upsert question")
    return row


@router.put("/quizzes/{quiz_id}/questions/{question_id}")
async def update_question(
    quiz_id: str,
    question_id: str,
    payload: schemas.QuizQuestionUpsert,
    current: TeacherUser,
):
    if not await models.quiz_belongs_to_user(quiz_id, current["id"]):
        raise HTTPException(status_code=403, detail="Not quiz owner")
    data = payload.model_dump(exclude_unset=True)
    data["id"] = question_id
    row = await models.upsert_quiz_question(quiz_id, data)
    if not row:
        raise HTTPException(status_code=404, detail="Question not found")
    return row


@router.delete("/quizzes/{quiz_id}/questions/{question_id}")
async def delete_question(quiz_id: str, question_id: str, current: TeacherUser):
    if not await models.quiz_belongs_to_user(quiz_id, current["id"]):
        raise HTTPException(status_code=403, detail="Not quiz owner")
    deleted = await models.delete_quiz_question(question_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Question not found")
    return {"deleted": True}
