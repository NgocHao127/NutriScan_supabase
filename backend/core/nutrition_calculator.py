from dataclasses import dataclass

ACTIVITY_MULTIPLIERS = {
    'Ít vận động (văn phòng)': 1.2,
    'Vận động nhẹ (1-3 ngày/tuần)': 1.375,
    'Vận động trung bình (3-5 ngày/tuần)': 1.55,
    'Vận động nhiều (6-7 ngày/tuần)': 1.725,
    'Vận động rất nhiều (công việc nặng hoặc tập luyện 2 lần/ngày)': 1.9,
}

BODY_SHAPE_FAT_PERCENT = {
    # Nam
    'Nam': {
        'Thon gọn': 0.12,
        'Săn chắc': 0.15,
        'Cơ bắp to': 0.18,
        'Bình thường': 0.20,
        'Thừa cân': 0.28,
        'Béo phì': 0.35,
    },
    # Nữ
    'Nữ': {
        'Thon gọn': 0.20,
        'Săn chắc': 0.24,
        'Cơ bắp to': 0.28,
        'Bình thường': 0.30,
        'Thừa cân': 0.38,
        'Béo phì': 0.45,
    },
    'Khác': {
        'Thon gọn': 0.16,
        'Săn chắc': 0.20,
        'Cơ bắp to': 0.23,
        'Bình thường': 0.25,
        'Thừa cân': 0.33,
        'Béo phì': 0.40,
    }
}

CALORIE_FLOOR = {
    'Nam': 1500,
    'Nữ': 1200,
    'Khác': 1350,
}

MACRO_RATIO = {
    'Giảm cân': {'protein': 0.35, 'carbs': 0.40, 'fat': 0.25},
    'Tăng cơ':  {'protein': 0.25, 'carbs': 0.50, 'fat': 0.25},
    'Duy trì':  {'protein': 0.25, 'carbs': 0.50, 'fat': 0.25},
    'Sức khỏe': {'protein': 0.25, 'carbs': 0.50, 'fat': 0.25},
}

@dataclass
class NutritionResult:
    tdee: float
    calorie_goal: int
    protein_goal: int
    carbs_goal: int
    fat_goal: int

def calc_lbm(weight: float, gender: str, body_shape: str = 'Bình thường') -> float:
    """Tính Lean Body Mass từ body shape."""
    fat_map = BODY_SHAPE_FAT_PERCENT.get(gender, BODY_SHAPE_FAT_PERCENT['Khác'])
    fat_percent = fat_map.get(body_shape, fat_map['Bình thường'])
    return weight * (1 - fat_percent)

def calc_bmr_katch_mcardle(lbm: float) -> float:
    """Katch-McArdle: chính xác hơn vì dựa trên LBM."""
    return 370 + (21.6 * lbm)

def calc_tdee(bmr: float, activity_level: str) -> float:
    """Tính TDEE từ BMR và mức vận động."""
    multiplier = ACTIVITY_MULTIPLIERS.get(activity_level, 1.2)
    return bmr * multiplier

def calc_calorie_goal(tdee: float, goal: str, gender: str) -> int:
    """Tính calo mục tiêu với calorie floor."""
    if goal == 'Giảm cân':
        target = tdee - 500
    elif goal == 'Tăng cơ':
        target = tdee + 500
    else:
        target = tdee

    floor = CALORIE_FLOOR.get(gender, 1350)
    return max(int(round(target)), floor)

def calc_macros(calorie_goal: int, goal: str) -> dict:
    """Phân bổ macro theo mục tiêu."""
    ratio = MACRO_RATIO.get(goal, MACRO_RATIO['Duy trì'])
    return {
        'protein_goal': int(calorie_goal * ratio['protein'] / 4),
        'carbs_goal':   int(calorie_goal * ratio['carbs'] / 4),
        'fat_goal':     int(calorie_goal * ratio['fat'] / 9),
    }


def calculate_nutrition(
    weight: float,
    gender: str,
    activity_level: str,
    goal: str,
    body_shape: str = 'Bình thường',
) -> NutritionResult:
    """Entry point — tính toàn bộ từ thông số người dùng."""
    lbm = calc_lbm(weight, gender, body_shape)
    bmr = calc_bmr_katch_mcardle(lbm)
    tdee = calc_tdee(bmr, activity_level)
    calorie_goal = calc_calorie_goal(tdee, goal, gender)
    macros = calc_macros(calorie_goal, goal)

    return NutritionResult(
        tdee=round(tdee, 1),
        calorie_goal=calorie_goal,
        protein_goal=macros['protein_goal'],
        carbs_goal=macros['carbs_goal'],
        fat_goal=macros['fat_goal'],
    )

def calc_bmi(weight: float, height: float) -> float:
    if height <= 0:
        return 0
    h_meters = height / 100
    return round(weight / (h_meters * h_meters), 1)

def bmi_category(bmi: float) -> str:
    if bmi < 18.5: return 'Thiếu cân'
    if bmi < 25: return 'Bình thường'
    if bmi < 30: return 'Thừa cân'
    return 'Béo phì'