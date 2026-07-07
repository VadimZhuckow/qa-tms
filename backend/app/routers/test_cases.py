from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from app.database import get_db
from app.models.test_case import TestCase
from app.schemas.test_case import TestCaseCreate, TestCaseUpdate, TestCaseResponse

router = APIRouter()

@router.get("/", response_model=List[TestCaseResponse])
def get_test_cases(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    test_cases = db.query(TestCase).offset(skip).limit(limit).all()
    return test_cases

@router.get("/{test_case_id}", response_model=TestCaseResponse)
def get_test_case(test_case_id: UUID, db: Session = Depends(get_db)):
    test_case = db.query(TestCase).filter(TestCase.id == test_case_id).first()
    if not test_case:
        raise HTTPException(status_code=404, detail="Test case not found")
    return test_case

@router.post("/", response_model=TestCaseResponse)
def create_test_case(test_case: TestCaseCreate, db: Session = Depends(get_db)):
    db_test_case = TestCase(**test_case.dict())
    db.add(db_test_case)
    db.commit()
    db.refresh(db_test_case)
    return db_test_case

@router.put("/{test_case_id}", response_model=TestCaseResponse)
def update_test_case(
    test_case_id: UUID,
    test_case_update: TestCaseUpdate,
    db: Session = Depends(get_db)
):
    db_test_case = db.query(TestCase).filter(TestCase.id == test_case_id).first()
    if not db_test_case:
        raise HTTPException(status_code=404, detail="Test case not found")
    
    update_data = test_case_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_test_case, key, value)
    
    db.commit()
    db.refresh(db_test_case)
    return db_test_case

@router.delete("/{test_case_id}")
def delete_test_case(test_case_id: UUID, db: Session = Depends(get_db)):
    db_test_case = db.query(TestCase).filter(TestCase.id == test_case_id).first()
    if not db_test_case:
        raise HTTPException(status_code=404, detail="Test case not found")
    
    db.delete(db_test_case)
    db.commit()
    return {"message": "Test case deleted"}
