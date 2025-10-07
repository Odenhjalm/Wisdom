from fastapi import APIRouter, HTTPException, Query

from .. import models, schemas
from ..auth import CurrentUser

router = APIRouter(prefix="/courses", tags=["courses"])
config_router = APIRouter(prefix="/config", tags=["config"])


@router.get("", response_model=schemas.CourseListResponse)
async def list_courses(
    published_only: bool = True,
    free_intro: bool | None = None,
    search: str | None = Query(default=None, min_length=2),
    limit: int | None = Query(default=None, ge=1, le=100),
):
    rows = await models.list_courses(
        published_only=published_only,
        free_intro=free_intro,
        search=search,
        limit=limit,
    )
    items = [schemas.Course(**row) for row in rows]
    return schemas.CourseListResponse(items=items)


router.add_api_route("/", list_courses, methods=["GET"], include_in_schema=False)

@router.get("/{course_id}/modules")
async def modules_for_course(course_id: str):
    modules = await models.list_modules(course_id)
    return {"items": modules}


@router.get("/modules/{module_id}/lessons")
async def lessons_for_module(module_id: str):
    lessons = await models.list_lessons(module_id)
    return {"items": lessons}


@router.get("/lessons/{lesson_id}")
async def lesson_detail(lesson_id: str):
    lesson = await models.get_lesson(lesson_id)
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    module = None
    if lesson.get("module_id"):
        module = await models.get_module_row(lesson["module_id"])
    modules = []
    course_lessons = []
    if module and module.get("course_id"):
        modules = list(await models.list_modules(module["course_id"]))
        course_lessons = list(await models.list_course_lessons(module["course_id"]))
    module_lessons = []
    if lesson.get("module_id"):
        module_lessons = list(await models.list_lessons(lesson["module_id"]))
    media = list(await models.list_lesson_media(lesson_id))
    return {
        "lesson": lesson,
        "module": module,
        "modules": modules,
        "module_lessons": module_lessons,
        "course_lessons": course_lessons,
        "media": media,
    }


@router.get("/me", response_model=schemas.CourseListResponse)
async def my_courses(current: CurrentUser):
    rows = await models.list_my_courses(current["id"])
    items = [schemas.Course(**row) for row in rows]
    return schemas.CourseListResponse(items=items)


@router.get("/{course_id}/enrollment")
async def enrollment_status(course_id: str, current: CurrentUser):
    enrolled = await models.is_enrolled(current["id"], course_id)
    return {"enrolled": enrolled}


@router.post("/{course_id}/enroll")
async def enroll_course(course_id: str, current: CurrentUser):
    success = await models.enroll_free_intro(current["id"], course_id)
    if not success:
        raise HTTPException(status_code=400, detail="Course is not free intro or already enrolled")
    return {"enrolled": True}


@router.get("/{course_id}/latest-order")
async def latest_order(course_id: str, current: CurrentUser):
    row = await models.latest_order_for_course(current["id"], course_id)
    return {"order": row}


@router.get("/free-consumed")
async def free_consumed(current: CurrentUser):
    count = await models.free_consumed_count(current["id"])
    limit = await models.free_course_limit()
    return {"consumed": count, "limit": limit}


@router.get("/config/free-limit")
async def free_limit():
    limit = await models.free_course_limit()
    return {"limit": limit}


router.add_api_route(
    "/config/free-course-limit",
    free_limit,
    methods=["GET"],
    include_in_schema=False,
)


@config_router.get("/free-course-limit")
async def global_free_course_limit():
    return await free_limit()


@router.get("/intro-first")
async def intro_first():
    rows = await models.list_courses(
        published_only=True,
        free_intro=True,
        limit=1,
    )
    course = rows[0] if rows else None
    return {"course": course}


@router.get("/{course_id}/access")
async def course_access(course_id: str, current: CurrentUser):
    snapshot = await models.course_access_snapshot(current["id"], course_id)
    return snapshot


@router.get("/{course_id}/quiz")
async def quiz_info(course_id: str, current: CurrentUser):
    info = await models.course_quiz_info(course_id, current["id"])
    return info


@router.get("/quiz/{quiz_id}/questions")
async def quiz_questions(quiz_id: str):
    rows = await models.quiz_questions(quiz_id)
    return {"items": rows}


@router.post("/quiz/{quiz_id}/submit")
async def quiz_submit(quiz_id: str, payload: schemas.QuizSubmission, current: CurrentUser):
    result = await models.submit_quiz(quiz_id, current["id"], payload.answers)
    return result


@router.get("/by-slug/{slug}")
async def course_detail_by_slug(slug: str):
    row = await models.get_course(slug=slug)
    if not row:
        raise HTTPException(status_code=404, detail="Course not found")
    course_id = row["id"]
    modules = await models.list_modules(course_id)
    module_ids = [m["id"] for m in modules]
    lessons_map: dict[str, list] = {}
    for module_id in module_ids:
        lessons_map[module_id] = list(await models.list_lessons(module_id))
    return {
        "course": row,
        "modules": modules,
        "lessons": lessons_map,
    }


@router.get("/{course_id}")
async def course_detail(course_id: str):
    row = await models.get_course(course_id=course_id)
    if not row:
        raise HTTPException(status_code=404, detail="Course not found")
    modules = await models.list_modules(course_id)
    module_ids = [m["id"] for m in modules]
    lessons_map: dict[str, list] = {}
    for module_id in module_ids:
        lessons_map[module_id] = list(await models.list_lessons(module_id))
    return {
        "course": row,
        "modules": modules,
        "lessons": lessons_map,
    }
