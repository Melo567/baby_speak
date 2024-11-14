enum StatusBaby {
  none("Background"),
  burp("Burp"),
  gaz("Gaz"),
  hungry("Hungry"),
  tired("Tired"),
  uncomfortable("Unconfortable");

  final String label;

  const StatusBaby(this.label);

  static StatusBaby fromLabel(String label) {
    return StatusBaby.values.firstWhere(
      (status) => status.label == label,
      orElse: () => StatusBaby.none, // Return null if no match is found
    );
  }
}
