from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime
from uuid import UUID

class TestCaseCreate(BaseModel):
    custom_id: Optional[str] = None
    title: str
    description: Optional[str] = ""
    preconditions: Optional[str] = ""
    steps: Optional[List[Dict[str, Any]]] = []
    expected_result: Optional[str] = ""
    test_data: Optional[Dict[str, Any]] = {}
    priority: Optional[str] = "medium"
    type: Optional[str] = "functional"
    automation_status: Optional[str] = "manual"
    tags: Optional[List[str]] = []
    suite_id: Optional[UUID] = None
    project_id: UUID
    workspace_id: UUID

class TestCaseUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    preconditions: Optional[str] = None
    steps: Optional[List[Dict[str, Any]]] = None
    expected_result: Optional[str] = None
    test_data: Optional[Dict[str, Any]] = None
    priority: Optional[str] = None
    type: Optional[str] = None
    automation_status: Optional[str] = None
    tags: Optional[List[str]] = None

class TestCaseResponse(BaseModel):
    id: UUID
    custom_id: str 
    title: str
    description: str
    preconditions: str
    steps: List[Dict[str, Any]]
    expected_result: str
    test_data: Dict[str, Any]
    priority: str
    type: str
    automation_status: str
    tags: List[str]
    suite_id: Optional[UUID]
    project_id: UUID
    workspace_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
