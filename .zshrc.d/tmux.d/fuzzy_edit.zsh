# Simple fuzzy file opener

getchar() {
	read -r -k 1 c
  c_val=$(printf "%d" "'$c'")
}

erase_line() {
	printf "\033[1A\033[2K"
}

cleanup() {
	echo "Exiting"
}

trap cleanup INT HUP TERM EXIT

getchar
while true; do
	if [ $c_val != 27 ]; then
		echo "pressed $c"
	else
		break
	fi
	getchar
	erase_line
done
