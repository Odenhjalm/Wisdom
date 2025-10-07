from fastapi import APIRouter

from .. import models

router = APIRouter(prefix="/landing", tags=["landing"])


@router.get("/intro-courses")
async def intro_courses():
    rows = await models.list_intro_courses()
    return {"items": rows}


@router.get("/popular-courses")
async def popular_courses():
    rows = await models.list_popular_courses()
    return {"items": rows}


@router.get("/teachers")
async def teachers():
    rows = await models.list_teachers()
    return {"items": rows}


@router.get("/services")
async def services():
    rows = await models.list_services()
    return {"items": rows}
