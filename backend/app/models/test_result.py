from sqlalchemy import Column, String, DateTime, Text, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base

class TestResult(Base):
    __tablename__ = "test_results"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=func.uuid_generate_v4())
    test_run_id = Column(UUID(as_uuid=True), ForeignKey("test_runs.id"), nullable=False)
    test_case_id = Column(UUID(as_uuid=True), ForeignKey("test_cases.id"), nullable=False)
    
    status = Column(String(20), default="not_run")
    comment = Column(Text, default="")
    defect_url = Column(String(500), default="")
    
    executed_by = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    executed_at = Column(DateTime(timezone=True))
    duration_seconds = Column(Integer, default=0)
    
    created_at = Column(DateTime(timezone=True), default=func.now())
    updated_at = Column(DateTime(timezone=True), default=func.now(), onupdate=func.now())
    
    test_run = relationship("TestRun")
    test_case = relationship("TestCase")
