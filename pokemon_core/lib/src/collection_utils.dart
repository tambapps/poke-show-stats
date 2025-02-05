

// yes, there isn't a list comparator in dart sdk...
bool listEquals<T>(List<T> l1, List<T> l2) { // note doesn't handle deep lists
  if (l1.length != l2.length) {
    return false;
  }
  for (int i = 0; i < l1.length; i++) {
    if (l1[i] != l2[i]) {
      return false;
    }
  }
  return true;
}