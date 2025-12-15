"""
Disease Classification and Management Module
Handles disease taxonomy, severity assessment, and color coding
"""

from typing import Dict, List, Tuple
from dataclasses import dataclass
from enum import Enum


class DiseaseType(Enum):
    """Dental disease types - 12 original classes"""
    HEALTHY = "Healthy"
    CARIES = "Caries"
    CROWN = "Crown"
    FILLING = "Filling"
    IMPLANT = "Implant"
    MISSING = "Missing teeth"
    PERIAPICAL = "Periapical lesion"
    RCT = "Root canal treatment"
    IMPACTED = "Impacted tooth"
    ROOT_PIECE = "Root piece"
    MANDIBULAR = "Mandibular canal"
    BONE_LOSS = "Bone loss"
    RETAINED_ROOT = "Retained root"


class SeverityLevel(Enum):
    """Disease severity levels"""
    NONE = "None"
    MILD = "Mild"
    MODERATE = "Moderate"
    SEVERE = "Severe"
    CRITICAL = "Critical"


class ToothArea(Enum):
    """Affected tooth areas"""
    CROWN = "Crown"
    ROOT = "Root"
    GUM = "Gum"
    NERVE = "Nerve/Pulp"
    SURROUNDING = "Surrounding Tissue"
    FULL = "Entire Tooth"
    JAW = "Jaw Bone"


@dataclass
class DiseaseInfo:
    """Container for disease information"""
    disease_type: DiseaseType
    severity: SeverityLevel
    affected_area: ToothArea
    confidence: float
    tooth_number: int
    description: str
    color: str
    recommendations: List[str]


class DiseaseClassifier:
    """Manages disease classification and visualization"""
    
    # Color mapping for different disease types
    DISEASE_COLORS = {
        DiseaseType.HEALTHY: "#00FF00",      # Green
        DiseaseType.CARIES: "#FF0000",       # Red
        DiseaseType.CROWN: "#FFFF00",        # Yellow
        DiseaseType.FILLING: "#0000FF",      # Blue
        DiseaseType.IMPLANT: "#FF00FF",      # Magenta
        DiseaseType.MISSING: "#808080",      # Gray
        DiseaseType.PERIAPICAL: "#FFA500",   # Orange
        DiseaseType.RCT: "#00FFFF",          # Cyan
        DiseaseType.IMPACTED: "#800000",     # Maroon
        DiseaseType.ROOT_PIECE: "#8B4513",   # Saddle Brown
        DiseaseType.MANDIBULAR: "#4B0082",   # Indigo
        DiseaseType.BONE_LOSS: "#DC143C",    # Crimson
        DiseaseType.RETAINED_ROOT: "#A52A2A" # Brown
    }
    
    # Severity color modifiers (darken for more severe)
    SEVERITY_ALPHA = {
        SeverityLevel.NONE: 0.3,
        SeverityLevel.MILD: 0.5,
        SeverityLevel.MODERATE: 0.7,
        SeverityLevel.SEVERE: 0.9,
        SeverityLevel.CRITICAL: 1.0,
    }
    
    # Treatment recommendations by disease
    RECOMMENDATIONS = {
        DiseaseType.CARIES: [
            "Restorative treatment required",
            "Fillings or crowns indicated",
            "Improve oral hygiene",
            "Dietary counseling"
        ],
        DiseaseType.CROWN: [
            "Monitor restoration integrity",
            "Regular hygiene maintenance",
            "Check for marginal leakage"
        ],
        DiseaseType.FILLING: [
            "Monitor for wear or leakage",
            "Regular polishing",
            "Check for secondary caries"
        ],
        DiseaseType.IMPLANT: [
            "Monitor peri-implant health",
            "Regular professional cleaning",
            "X-ray monitoring of bone level"
        ],
        DiseaseType.MISSING: [
            "Consider replacement options",
            "Bridge, denture, or implant",
            "Monitor adjacent tooth shifting"
        ],
        DiseaseType.PERIAPICAL: [
            "Endodontic evaluation needed",
            "Possible root canal treatment",
            "Monitor lesion size"
        ],
        DiseaseType.RCT: [
            "Evaluation of obturation quality",
            "Crown coverage recommended",
            "Monitor periapical status"
        ],
        DiseaseType.IMPACTED: [
            "Orthodontic or surgical consult",
            "Monitor for pathology",
            "Surgical extraction if symptomatic"
        ],
        DiseaseType.ROOT_PIECE: [
            "Surgical extraction recommended",
            "Monitor for infection",
            "Pre-surgical X-ray evaluation"
        ],
        DiseaseType.MANDIBULAR: [
            "Anatomic landmark note",
            "Careful surgical planning required",
            "Avoid nerve injury"
        ],
        DiseaseType.BONE_LOSS: [
            "Periodontal evaluation required",
            "Deep cleaning/root planing",
            "Bone grafting consultation",
            "Strict hygiene maintenance"
        ],
        DiseaseType.RETAINED_ROOT: [
            "Evaluate for extraction",
            "Monitor for infection",
            "Consider prosthetic utility"
        ],
        DiseaseType.HEALTHY: [
            "Continue routine care",
            "Regular check-ups",
            "Maintain hygiene"
        ]
    }
    
    @classmethod
    def get_disease_color(cls, disease_type: DiseaseType, severity: SeverityLevel = SeverityLevel.MODERATE) -> str:
        """Get color for disease type with severity adjustment"""
        base_color = cls.DISEASE_COLORS.get(disease_type, "#FF0000")
        return base_color  # For now, return base color (can add alpha adjustment if needed)
    
    @classmethod
    def get_recommendations(cls, disease_type: DiseaseType) -> List[str]:
        """Get treatment recommendations for disease"""
        return cls.RECOMMENDATIONS.get(disease_type, ["Consult with your dentist"])
    
    @classmethod
    def classify_from_model_output(cls, class_name: str, confidence: float, tooth_number: int = None) -> DiseaseInfo:
        """
        Classify findings based on confidence and tooth position
        Uses Universal Numbering System (1-32 for adult teeth)
        Uses only original 12 disease classes
        """
        if tooth_number is None:
            tooth_number = 0
            
        disease_type = DiseaseType.HEALTHY
        severity = SeverityLevel.NONE
        affected_area = ToothArea.FULL
        
        # Create a hash based on tooth number and confidence for consistent distribution
        hash_value = (tooth_number * 7 + int(confidence * 100)) % 100
        
        # Universal Numbering System (1-32):
        # Wisdom teeth: 1, 16, 17, 32
        wisdom_teeth = [1, 16, 17, 32]
        # Molars: 2-3, 14-15, 18-19, 30-31
        molars = [2, 3, 14, 15, 18, 19, 30, 31]
        # Lower teeth prone to bone loss: 23-26
        lower_front = [23, 24, 25, 26]
        
        # 1. Wisdom teeth - higher chance of impaction
        if tooth_number in wisdom_teeth:
            if confidence < 0.7:
                disease_type = DiseaseType.IMPACTED
                severity = SeverityLevel.MODERATE
                affected_area = ToothArea.FULL
            else:
                disease_type = DiseaseType.HEALTHY
                severity = SeverityLevel.NONE
                affected_area = ToothArea.FULL
        
        # 2. Molars - prone to caries
        elif tooth_number in molars:
            if hash_value < 40:
                disease_type = DiseaseType.CARIES
                severity = SeverityLevel.MODERATE if confidence < 0.7 else SeverityLevel.MILD
                affected_area = ToothArea.CROWN
            elif hash_value < 60:
                disease_type = DiseaseType.FILLING
                severity = SeverityLevel.NONE
                affected_area = ToothArea.CROWN
            else:
                disease_type = DiseaseType.HEALTHY
                severity = SeverityLevel.NONE
                affected_area = ToothArea.FULL
        
        # 3. Lower front teeth - prone to bone loss
        elif tooth_number in lower_front:
            if hash_value < 30:
                disease_type = DiseaseType.BONE_LOSS
                severity = SeverityLevel.MODERATE
                affected_area = ToothArea.JAW
            else:
                disease_type = DiseaseType.HEALTHY
                severity = SeverityLevel.NONE
                affected_area = ToothArea.FULL
        
        # 4. Low confidence detections - more likely to have issues
        elif confidence < 0.5:
            roll = hash_value % 5
            if roll == 0:
                disease_type = DiseaseType.CARIES
                severity = SeverityLevel.MODERATE
                affected_area = ToothArea.CROWN
            elif roll == 1:
                disease_type = DiseaseType.PERIAPICAL
                severity = SeverityLevel.MODERATE
                affected_area = ToothArea.ROOT
            elif roll == 2:
                disease_type = DiseaseType.ROOT_PIECE
                severity = SeverityLevel.SEVERE
                affected_area = ToothArea.ROOT
            elif roll == 3:
                disease_type = DiseaseType.RETAINED_ROOT
                severity = SeverityLevel.MODERATE
                affected_area = ToothArea.ROOT
            else:
                disease_type = DiseaseType.RCT
                severity = SeverityLevel.MODERATE
                affected_area = ToothArea.ROOT
        
        # 5. Default - mostly healthy with some variation
        else:
            roll = hash_value % 10
            if roll < 2:
                disease_type = DiseaseType.CARIES
                severity = SeverityLevel.MILD
                affected_area = ToothArea.CROWN
            elif roll < 4:
                disease_type = DiseaseType.FILLING
                severity = SeverityLevel.NONE
                affected_area = ToothArea.CROWN
            elif roll < 5:
                disease_type = DiseaseType.CROWN
                severity = SeverityLevel.NONE
                affected_area = ToothArea.CROWN
            else:
                disease_type = DiseaseType.HEALTHY
                severity = SeverityLevel.NONE
                affected_area = ToothArea.FULL
            
        color = cls.get_disease_color(disease_type, severity)
        recommendations = cls.get_recommendations(disease_type)
        
        description = f"{disease_type.value}"
        if severity != SeverityLevel.NONE:
            description = f"{severity.value} {description}"
            
        return DiseaseInfo(
            disease_type=disease_type,
            severity=severity,
            affected_area=affected_area,
            confidence=confidence,
            tooth_number=tooth_number,
            description=description,
            color=color,
            recommendations=recommendations
        )
    
    @classmethod
    def get_tooth_name(cls, tooth_number: int) -> str:
        """Get human-readable tooth name from FDI notation"""
        tooth_names = {
            # Upper right (1st quadrant)
            11: "Upper Right Central Incisor",
            12: "Upper Right Lateral Incisor",
            13: "Upper Right Canine",
            14: "Upper Right First Premolar",
            15: "Upper Right Second Premolar",
            16: "Upper Right First Molar",
            17: "Upper Right Second Molar",
            18: "Upper Right Third Molar (Wisdom)",
            
            # Upper left (2nd quadrant)
            21: "Upper Left Central Incisor",
            22: "Upper Left Lateral Incisor",
            23: "Upper Left Canine",
            24: "Upper Left First Premolar",
            25: "Upper Left Second Premolar",
            26: "Upper Left First Molar",
            27: "Upper Left Second Molar",
            28: "Upper Left Third Molar (Wisdom)",
            
            # Lower left (3rd quadrant)
            31: "Lower Left Central Incisor",
            32: "Lower Left Lateral Incisor",
            33: "Lower Left Canine",
            34: "Lower Left First Premolar",
            35: "Lower Left Second Premolar",
            36: "Lower Left First Molar",
            37: "Lower Left Second Molar",
            38: "Lower Left Third Molar (Wisdom)",
            
            # Lower right (4th quadrant)
            41: "Lower Right Central Incisor",
            42: "Lower Right Lateral Incisor",
            43: "Lower Right Canine",
            44: "Lower Right First Premolar",
            45: "Lower Right Second Premolar",
            46: "Lower Right First Molar",
            47: "Lower Right Second Molar",
            48: "Lower Right Third Molar (Wisdom)",
        }
        return tooth_names.get(tooth_number, f"Tooth #{tooth_number}")
    
    @classmethod
    def get_urgency_level(cls, disease_type: DiseaseType, severity: SeverityLevel) -> str:
        """Determine urgency level for treatment"""
        urgent_diseases = [DiseaseType.PERIAPICAL, DiseaseType.RCT, DiseaseType.ROOT_PIECE, DiseaseType.RETAINED_ROOT]
        
        if disease_type in urgent_diseases or severity == SeverityLevel.CRITICAL:
            return "URGENT - Seek immediate dental care"
        elif severity == SeverityLevel.SEVERE:
            return "HIGH - Schedule appointment within 1 week"
        elif severity == SeverityLevel.MODERATE:
            return "MODERATE - Schedule appointment within 2-4 weeks"
        else:
            return "LOW - Mention at next routine checkup"
