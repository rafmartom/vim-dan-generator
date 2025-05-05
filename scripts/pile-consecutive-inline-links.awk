{
  # Store the current line in the "current" variable
  current = $0;

  # If the line matches the pattern, check the next line
  if (current ~ /(<I=[a-zA-Z0-9]+>)+$/) {
    # Save the next line into "nextLine" variable
    getline nextLine;

    # If the next line matches the same pattern, append it
    if (nextLine ~ /^(<I=[a-zA-Z0-9]+>)*$/) {
      printf("%s%s\n", current, nextLine); # Append the two lines together
      next; # Skip the next line (it's already processed)
    } else {
      print current; # If next line does not match, print current
      print nextLine; # Print the next line normally
    }
} else {
    print current; # If the current line doesn't match, print it
  }
}
