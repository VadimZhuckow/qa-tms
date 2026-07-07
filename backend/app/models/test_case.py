from sqlalchemy import Column, String, DateTime, Text, ForeignKey, JSON, ARRAY
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base

class TestCase(Base):
    __tablename__ = "test_cases"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=func.uuid_generate_v4())
    suite_id = Column(UUID(as_uuid=True), ForeignKey("suites.id"))
    project_id = Column(UUID(as_uuid=True), ForeignKey("projects.id"), nullable=False)
    workspace_id = Column(UUID(as_uuid=True), ForeignKey("workspaces.id"), nullable=False)
    
    title = Column(String(500), nullable=False)
    description = Column(Text, default="")
    preconditions = Column(Text, default="")
    steps = Column(JSON, default=[])
    expected_result = Column(Text, default="")
    test_data = Column(JSON, default={})
    
    priority = Column(String(20), default="medium")
    type = Column(String(30), default="functional")
    automation_status = Column(String(20), default="manual")
    
    tags = Column(ARRAY(String), default=[])
    
    created_by = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    created_at = Column(DateTime(timezone=True), default=func.now())
    updated_at = Column(DateTime(timezone=True), default=func.now(), onupdate=func.now())
    
    suite = relationship("Suite")
    project = relationship("Project")
