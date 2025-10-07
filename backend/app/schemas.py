from datetime import datetime
from typing import Any, List, Optional

from pydantic import BaseModel, EmailStr
from uuid import UUID


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    refresh_token: str


class TokenPayload(BaseModel):
    sub: UUID


class AuthLoginRequest(BaseModel):
    email: EmailStr
    password: str


class AuthRegisterRequest(BaseModel):
    email: EmailStr
    password: str
    display_name: str


class AuthForgotPasswordRequest(BaseModel):
    email: EmailStr


class AuthResetPasswordRequest(BaseModel):
    email: EmailStr
    new_password: str


class TokenRefreshRequest(BaseModel):
    refresh_token: str


class Profile(BaseModel):
    user_id: UUID
    email: EmailStr
    display_name: str | None = None
    bio: str | None = None
    photo_url: str | None = None
    avatar_media_id: UUID | None = None
    role_v2: str
    is_admin: bool
    created_at: datetime
    updated_at: datetime


class SimpleProfile(BaseModel):
    user_id: UUID
    display_name: Optional[str] = None
    photo_url: Optional[str] = None
    bio: Optional[str] = None


class CommunityPost(BaseModel):
    id: UUID
    author_id: UUID
    content: str
    media_paths: List[str] = []
    created_at: datetime
    profile: Optional[SimpleProfile] = None


class CommunityPostCreate(BaseModel):
    content: str
    media_paths: Optional[List[str]] = None


class CommunityPostListResponse(BaseModel):
    items: List[CommunityPost]


class TeacherDirectoryItem(BaseModel):
    user_id: UUID
    headline: Optional[str] = None
    specialties: List[str] = []
    rating: Optional[float] = None
    created_at: datetime
    profile: Optional[SimpleProfile] = None
    verified_certificates: int = 0


class TeacherDirectoryResponse(BaseModel):
    items: List[TeacherDirectoryItem]


class ServiceSummary(BaseModel):
    id: UUID
    title: str
    description: Optional[str] = None
    price_cents: Optional[int] = None
    duration_min: Optional[int] = None
    certified_area: Optional[str] = None
    active: Optional[bool] = None
    created_at: datetime


class MeditationSummary(BaseModel):
    id: UUID
    teacher_id: UUID
    title: str
    description: Optional[str] = None
    audio_path: str
    duration_seconds: Optional[int] = None
    is_public: bool | None = None
    created_at: datetime
    audio_url: Optional[str] = None


class TeacherDetailResponse(BaseModel):
    teacher: Optional[TeacherDirectoryItem] = None
    services: List[ServiceSummary] = []
    meditations: List[MeditationSummary] = []
    certificates: List[dict[str, Any]] = []


class ReviewRecord(BaseModel):
    id: UUID
    service_id: UUID
    reviewer_id: UUID
    rating: int
    comment: Optional[str] = None
    created_at: datetime


class ReviewListResponse(BaseModel):
    items: List[ReviewRecord]


class ReviewCreate(BaseModel):
    rating: int
    comment: Optional[str] = None


class MeditationListResponse(BaseModel):
    items: List[MeditationSummary]


class MessageRecord(BaseModel):
    id: UUID
    channel: str
    sender_id: UUID
    content: str
    created_at: datetime


class MessageListResponse(BaseModel):
    items: List[MessageRecord]


class MessageCreate(BaseModel):
    channel: str
    content: str


class ServiceDetailResponse(BaseModel):
    service: Optional[dict[str, Any]] = None
    provider: Optional[dict[str, Any]] = None


class TarotRequestRecord(BaseModel):
    id: UUID
    requester_id: UUID
    reader_id: Optional[UUID] = None
    question: str
    status: str
    deliverable_url: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class TarotRequestListResponse(BaseModel):
    items: List[TarotRequestRecord]


class TarotRequestCreate(BaseModel):
    question: str


class TeacherApplication(BaseModel):
    id: UUID
    user_id: UUID
    title: str
    status: str
    notes: Optional[str] = None
    evidence_url: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    display_name: Optional[str] = None
    email: Optional[EmailStr] = None
    role_v2: Optional[str] = None
    approval: Optional[dict[str, Any]] = None


class CertificateRecord(BaseModel):
    id: UUID
    user_id: UUID
    title: str
    status: str
    notes: Optional[str] = None
    evidence_url: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class AdminDashboard(BaseModel):
    is_admin: bool
    requests: List[TeacherApplication]
    certificates: List[CertificateRecord]


class CertificateStatusUpdate(BaseModel):
    status: str


class NotificationRecord(BaseModel):
    id: UUID
    kind: str
    payload: dict[str, Any]
    is_read: bool
    created_at: datetime


class NotificationListResponse(BaseModel):
    items: List[NotificationRecord]


class NotificationUpdate(BaseModel):
    is_read: bool


class ProfileDetail(BaseModel):
    profile: dict[str, Any]
    is_following: bool
    services: List[dict[str, Any]]
    meditations: List[dict[str, Any]]


class ProfileDetailResponse(ProfileDetail):
    pass


class Course(BaseModel):
    id: UUID
    slug: str
    title: str
    description: str | None = None
    cover_url: str | None = None
    video_url: str | None = None
    is_free_intro: bool
    price_cents: int | None = None
    is_published: bool
    created_by: UUID | None
    created_at: datetime
    updated_at: datetime


class CourseListResponse(BaseModel):
    items: List[Course]


class QuizSubmission(BaseModel):
    answers: dict


class StudioCourseCreate(BaseModel):
    title: str
    slug: str
    description: str | None = None
    cover_url: str | None = None
    video_url: str | None = None
    is_free_intro: bool = False
    is_published: bool = False
    price_cents: int | None = None
    branch: str | None = None


class StudioCourseUpdate(BaseModel):
    title: str | None = None
    slug: str | None = None
    description: str | None = None
    cover_url: str | None = None
    video_url: str | None = None
    is_free_intro: bool | None = None
    is_published: bool | None = None
    price_cents: int | None = None
    branch: str | None = None


class StudioModuleCreate(BaseModel):
    course_id: str
    title: str
    position: int = 0


class StudioModuleUpdate(BaseModel):
    title: str | None = None
    position: int | None = None


class StudioLessonCreate(BaseModel):
    module_id: str
    title: str
    content_markdown: str | None = None
    position: int = 0
    is_intro: bool = False


class StudioLessonUpdate(BaseModel):
    title: str | None = None
    content_markdown: str | None = None
    position: int | None = None
    is_intro: bool | None = None


class LessonIntroUpdate(BaseModel):
    is_intro: bool


class MediaReorder(BaseModel):
    media_ids: List[str]


class QuizEnsureResult(BaseModel):
    quiz: dict


class QuizQuestionUpsert(BaseModel):
    id: str | None = None
    position: int | None = None
    kind: str | None = None
    prompt: str | None = None
    options: dict | None = None
    correct: str | None = None


class SubscriptionPlan(BaseModel):
    id: UUID
    name: str
    price_cents: int
    interval: str
    is_active: bool


class SubscriptionPlanListResponse(BaseModel):
    items: List[SubscriptionPlan]


class SubscriptionStatusResponse(BaseModel):
    has_active: bool
    subscription: Optional[dict[str, Any]] = None


class CouponPreviewRequest(BaseModel):
    plan_id: UUID
    code: Optional[str] = None


class CouponPreviewResponse(BaseModel):
    valid: bool
    pay_amount_cents: int


class CouponRedeemRequest(BaseModel):
    plan_id: UUID
    code: str


class CouponRedeemResponse(BaseModel):
    ok: bool
    reason: Optional[str] = None
    subscription: Optional[dict[str, Any]] = None


class OrderRecord(BaseModel):
    id: UUID
    user_id: UUID
    course_id: Optional[UUID] = None
    service_id: Optional[UUID] = None
    amount_cents: int
    currency: str
    status: str
    stripe_checkout_id: Optional[str] = None
    stripe_payment_intent: Optional[str] = None
    metadata: Optional[dict[str, Any]] = None
    created_at: datetime
    updated_at: datetime


class OrderResponse(BaseModel):
    order: OrderRecord


class OrderCourseCreateRequest(BaseModel):
    course_id: UUID
    amount_cents: int
    currency: Optional[str] = "sek"
    metadata: Optional[dict[str, Any]] = None


class OrderServiceCreateRequest(BaseModel):
    service_id: UUID
    amount_cents: int
    currency: Optional[str] = "sek"
    metadata: Optional[dict[str, Any]] = None


class CreateCheckoutSessionRequest(BaseModel):
    order_id: UUID
    success_url: str
    cancel_url: str
    customer_email: Optional[str] = None


class CheckoutSessionResponse(BaseModel):
    url: str
    id: Optional[str] = None


class CreateSubscriptionRequest(BaseModel):
    user_id: UUID
    price_id: str


class CreateSubscriptionResponse(BaseModel):
    subscription_id: str
    client_secret: Optional[str] = None
    status: Optional[str] = None


class CancelSubscriptionRequest(BaseModel):
    subscription_id: str


class ProfileUpdate(BaseModel):
    display_name: Optional[str] = None
    bio: Optional[str] = None
    photo_url: Optional[str] = None


class StudioCertificateCreate(BaseModel):
    title: str
    status: str = "pending"
    notes: Optional[str] = None
    evidence_url: Optional[str] = None


class PurchaseClaimRequest(BaseModel):
    token: UUID


class PurchaseClaimResponse(BaseModel):
    ok: bool
