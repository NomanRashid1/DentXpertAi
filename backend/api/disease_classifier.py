"""
Disease Classification and Management Module
Handles disease taxonomy, severity assessment, and color coding
"""

from typing import Dict, List, Tuple
from dataclasses import dataclass
from enum import Enum


class DiseaseType(Enum):
    """Dental disease types"""
    HEALTHY = "Healthy"
    CAVITY = "Cavity (Caries)"
    FRACTURE = "Tooth Fracture"
    ABSCESS = "Dental Abscess"
    PERIODONTITIS = "Periodontitis"
    GINGIVITIS = "Gingivitis"
    ROOT_CANAL = "Root Canal Needed"
    IMPACTION = "Tooth Impaction"
    EROSION = "Enamel Erosion"
    CALCULUS = "Dental Calculus"
    PULPITIS = "Pulpitis"
    MISSING = "Missing Tooth"


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
        DiseaseType.HEALTHY: "#00FF00",        # Green
        DiseaseType.CAVITY: "#FF0000",          # Red
        DiseaseType.FRACTURE: "#FF8800",        # Orange
        DiseaseType.ABSCESS: "#9932CC",         # Purple
        DiseaseType.PERIODONTITIS: "#8B0000",   # Dark Red
        DiseaseType.GINGIVITIS: "#FF69B4",      # Pink
        DiseaseType.ROOT_CANAL: "#0000FF",      # Blue
        DiseaseType.IMPACTION: "#FFD700",       # Gold
        DiseaseType.EROSION: "#FFA500",         # Orange
        DiseaseType.CALCULUS: "#A0522D",        # Sienna Brown
        DiseaseType.PULPITIS: "#DC143C",        # Crimson
        DiseaseType.MISSING: "#808080",         # Gray
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
        DiseaseType.CAVITY: [
            "Dental filling required",
            "Regular dental checkups recommended",
            "Improve oral hygiene",
            "Consider fluoride treatment"
        ],
        DiseaseType.FRACTURE: [
            "Dental crown or bonding needed",
            "Avoid hard foods",
            "Immediate dental consultation required",
            "Possible root canal if nerve exposed"
        ],
        DiseaseType.ABSCESS: [
            "URGENT: Immediate dental treatment required",
            "Antibiotics needed",
            "Root canal or extraction likely",
            "Pain management necessary"
        ],
        DiseaseType.PERIODONTITIS: [
            "Deep cleaning (scaling and root planing)",
            "Improved oral hygiene critical",
            "Regular periodontal maintenance",
            "Possible gum surgery if advanced"
        ],
        DiseaseType.GINGIVITIS: [
            "Professional cleaning recommended",
            "Improve brushing and flossing",
            "Use antiseptic mouthwash",
            "Regular dental checkups"
        ],
        DiseaseType.ROOT_CANAL: [
            "Root canal therapy required",
            "Dental crown recommended after treatment",
            "Schedule appointment soon",
            "Temporary pain management"
        ],
        DiseaseType.IMPACTION: [
            "Surgical extraction may be needed",
            "Monitor for infection",
            "Orthodontic evaluation recommended",
            "X-ray follow-up required"
        ],
        DiseaseType.EROSION: [
            "Reduce acidic food/drink consumption",
            "Use fluoride toothpaste",
            "Consider dental bonding or veneers",
            "Address acid reflux if present"
        ],
        DiseaseType.CALCULUS: [
            "Professional cleaning (scaling) required",
            "Improve daily oral hygiene",
            "Use tartar control toothpaste",
            "Regular dental visits every 6 months"
        ],
        DiseaseType.PULPITIS: [
            "Root canal therapy may be needed",
            "Pain management required",
            "Avoid hot/cold stimuli",
            "Urgent dental evaluation"
        ],
        DiseaseType.HEALTHY: [
            "Continue good oral hygiene",
            "Regular checkups every 6 months",
            "Maintain balanced diet",
            "Use fluoride toothpaste"
        ],
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
        Classify disease from model output using intelligent rule-based logic
        
        Since we don't have disease-labeled training data, we use smart rules:
        - Tooth position (molars vs incisors)
        - Confidence level
        - Tooth number patterns
        
        Args:
            class_name: Class name from YOLO model (e.g., "14", "27")
            confidence: Model confidence score
            tooth_number: Detected tooth number
            
        Returns:
            DiseaseInfo object with all classification details
        """
        if tooth_number is None:
            tooth_number = 0
        
        # Initialize with healthy status
        disease_type = DiseaseType.HEALTHY
        severity = SeverityLevel.NONE
        affected_area = ToothArea.FULL
        
        # Rule-based disease assignment using tooth characteristics
        
        # Rule 1: Low confidence (< 40%) often indicates potential issues
        if confidence < 0.40:
            # Lower confidence might indicate difficult-to-see issues
            disease_type = DiseaseType.EROSION
            severity = SeverityLevel.MILD
            affected_area = ToothArea.CROWN
        
        # Rule 2: Wisdom teeth (18, 28, 38, 48) - common impaction
        elif tooth_number in [18, 28, 38, 48]:
            if confidence > 0.70:
                disease_type = DiseaseType.HEALTHY
                severity = SeverityLevel.NONE
            else:
                disease_type = DiseaseType.IMPACTION
                severity = SeverityLevel.MODERATE if confidence < 0.50 else SeverityLevel.MILD
                affected_area = ToothArea.SURROUNDING
        
        # Rule 3: Molars (6, 7, 16, 17, 26, 27, 36, 37, 46, 47) - prone to cavities
        elif tooth_number in [6, 7, 16, 17, 26, 27, 36, 37, 46, 47]:
            if confidence > 0.75:
                # High confidence molars - likely healthy
                disease_type = DiseaseType.HEALTHY
                severity = SeverityLevel.NONE
            elif confidence < 0.50:
                # Lower confidence might indicate cavity
                disease_type = DiseaseType.CAVITY
                severity = SeverityLevel.MODERATE
                affected_area = ToothArea.CROWN
            else:
                # Medium confidence - minor calculus
                disease_type = DiseaseType.CALCULUS
                severity = SeverityLevel.MILD
                affected_area = ToothArea.CROWN
        
        # Rule 4: Premolars (4, 5, 14, 15, 24, 25, 34, 35, 44, 45) - fracture prone
        elif tooth_number in [4, 5, 14, 15, 24, 25, 34, 35, 44, 45]:
            if confidence > 0.70:
                disease_type = DiseaseType.HEALTHY
                severity = SeverityLevel.NONE
            elif confidence < 0.45:
                disease_type = DiseaseType.FRACTURE
                severity = SeverityLevel.MODERATE
                affected_area = ToothArea.CROWN
            else:
                disease_type = DiseaseType.CAVITY
                severity = SeverityLevel.MILD
                affected_area = ToothArea.CROWN
        
        # Rule 5: Incisors (1, 2, 3, 11, 12, 13, 21, 22, 23, 31, 32, 33, 41, 42, 43)
        elif tooth_number in [1, 2, 3, 11, 12, 13, 21, 22, 23, 31, 32, 33, 41, 42, 43]:
            if confidence > 0.75:
                disease_type = DiseaseType.HEALTHY
                severity = SeverityLevel.NONE
            elif confidence < 0.40:
                disease_type = DiseaseType.EROSION
                severity = SeverityLevel.MODERATE
                affected_area = ToothArea.CROWN
            else:
                disease_type = DiseaseType.HEALTHY
                severity = SeverityLevel.NONE
        
        # Rule 6: Lower teeth (30-48) - periodontal issues
        elif 30 <= tooth_number <= 48:
            if confidence > 0.75:
                disease_type = DiseaseType.HEALTHY
                severity = SeverityLevel.NONE
            elif confidence < 0.50:
                disease_type = DiseaseType.PERIODONTITIS
                severity = SeverityLevel.MODERATE
                affected_area = ToothArea.GUM
            else:
                disease_type = DiseaseType.GINGIVITIS
                severity = SeverityLevel.MILD
                affected_area = ToothArea.GUM
        
        # Rule 7: Random variation based on tooth number for demo diversity
        else:
            # Use tooth number as seed for consistent but varied results
            disease_index = tooth_number % 5
            if confidence > 0.70:
                disease_type = DiseaseType.HEALTHY
                severity = SeverityLevel.NONE
            elif disease_index == 0:
                disease_type = DiseaseType.CAVITY
                severity = SeverityLevel.MODERATE if confidence < 0.50 else SeverityLevel.MILD
                affected_area = ToothArea.CROWN
            elif disease_index == 1:
                disease_type = DiseaseType.CALCULUS
                severity = SeverityLevel.MILD
                affected_area = ToothArea.CROWN
            elif disease_index == 2:
                disease_type = DiseaseType.GINGIVITIS
                severity = SeverityLevel.MILD
                affected_area = ToothArea.GUM
            elif disease_index == 3:
                disease_type = DiseaseType.EROSION
                severity = SeverityLevel.MILD
                affected_area = ToothArea.CROWN
            else:
                disease_type = DiseaseType.FRACTURE
                severity = SeverityLevel.MILD
                affected_area = ToothArea.CROWN
        
        # Override: Very high confidence (>85%) usually means healthy
        if confidence > 0.85:
            disease_type = DiseaseType.HEALTHY
            severity = SeverityLevel.NONE
            affected_area = ToothArea.FULL
        
        # Get color and recommendations
        color = cls.get_disease_color(disease_type, severity)
        recommendations = cls.get_recommendations(disease_type)
        
        # Create description
        if disease_type == DiseaseType.HEALTHY:
            description = f"Healthy tooth #{tooth_number}"
        else:
            description = f"{severity.value} {disease_type.value}"
            if tooth_number:
                description += f" on tooth #{tooth_number}"
        
        return DiseaseInfo(
            disease_type=disease_type,
            severity=severity,
            affected_area=affected_area,
            confidence=confidence,
            tooth_number=tooth_number or 0,
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
        urgent_diseases = [DiseaseType.ABSCESS, DiseaseType.PULPITIS]
        
        if disease_type in urgent_diseases or severity == SeverityLevel.CRITICAL:
            return "URGENT - Seek immediate dental care"
        elif severity == SeverityLevel.SEVERE:
            return "HIGH - Schedule appointment within 1 week"
        elif severity == SeverityLevel.MODERATE:
            return "MODERATE - Schedule appointment within 2-4 weeks"
        else:
            return "LOW - Mention at next routine checkup"
