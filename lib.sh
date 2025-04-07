spinners=(line dot minidot jump pulse points meter hamburger)
spinner () {
    shuf -e ${spinners[@]} -n 1
}

exists() {
    command -v "$1" >/dev/null 2>&1
}
