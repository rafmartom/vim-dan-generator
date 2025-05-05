  /^<I=[a-zA-Z0-9]+>/ {
    printf("%s\n", $0);  # Print the E-Mail line *appended* to the previous line
    found = 1;            # Mark that we just handled an E-Mail line
    next;                 # Skip further processing for this line
  }

  !/^<I=[a-zA-Z0-9]+>/ {
    printf((line == 0 || found == 1) ? "%s" : "\n%s", $0);
    found = 0;            # Reset the flag if this isn't an E-Mail line
    line++;
  }
END {
  print "";
}
