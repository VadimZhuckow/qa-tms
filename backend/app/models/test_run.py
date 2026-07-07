from sqlalchemy import Column, String, DateTime, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base

class TestRun(Base):
    __tablename__ = "test_runs"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=func.uuid_generate_v4())
    workspace_id = Column(UUID(as_uuid=True), ForeignKey("workspaces.id"), nullable=False)
    project_id = Column(UUID(as_uuid=True), ForeignKey("projects.id"), nullable=False)
    
    name = Column(String(255), nullable=False)
    description = Column(Text, default="")
    run_type = Column(String(30), default="manual")
    status = Column(String(20), default="in_progress")
    
    started_at = Column(DateTime(timezone=True))
    finished_at = Column(DateTime(timezone=True))
    
    created_by = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    created_at = Column(DateTime(timezone=True), default=func.now())
    updated_at = Column(DateTime(timezone=True), default=func.now(), onupdate=func.now())
    
    workspace = relationship("Workspace")
    project = relationship("Project")
