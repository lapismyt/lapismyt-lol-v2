function updateAge() {
    const birthDateStr = "2008-12-05";
    const birthDate = new Date(birthDateStr);
    const now = new Date();
    const diffMs = now.getTime() - birthDate.getTime();

    const msInYear = 1000 * 60 * 60 * 24 * 365.25;

    const ageInYears = diffMs / msInYear;

    const ageSpan = document.getElementById('age');
    if (ageSpan) {
        ageSpan.textContent = ageInYears.toFixed(7);
    }
}