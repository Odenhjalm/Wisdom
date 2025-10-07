from fastapi import APIRouter, HTTPException, Response, status

from .. import models, schemas
from ..auth import CurrentUser
from ..permissions import AdminUser

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/dashboard", response_model=schemas.AdminDashboard)
async def admin_dashboard(current: CurrentUser):
    is_admin = await models.is_admin_user(current["id"])
    if not is_admin:
        return schemas.AdminDashboard(
            is_admin=False,
            requests=[],
            certificates=[],
        )
    requests = await models.list_teacher_applications()
    certificates = await models.list_recent_certificates()
    return schemas.AdminDashboard(
        is_admin=True,
        requests=requests,
        certificates=certificates,
    )


@router.post("/teachers/{user_id}/approve", status_code=status.HTTP_204_NO_CONTENT)
async def admin_approve_teacher(user_id: str, current: AdminUser):
    await models.approve_teacher_user(user_id, current["id"])
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/teachers/{user_id}/reject", status_code=status.HTTP_204_NO_CONTENT)
async def admin_reject_teacher(user_id: str, current: AdminUser):
    await models.reject_teacher_user(user_id, current["id"])
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.patch(
    "/certificates/{certificate_id}",
    response_model=schemas.CertificateRecord,
)
async def admin_update_certificate(
    certificate_id: str,
    payload: schemas.CertificateStatusUpdate,
    current: AdminUser,
):
    row = await models.set_certificate_status(certificate_id, payload.status)
    if not row:
        raise HTTPException(status_code=404, detail="Certificate not found")
    return row
