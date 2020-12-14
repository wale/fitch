set -g __fitch_os ""
set -g __fitch_title ""
set -g __fitch_distro ""

# Sets the kernel name, we'll need it.
set -g __fitch_kernel_name (uname -s)

function fitch -a cmd -d "System information tool"

end

## half of these functions are basically ports from neofetch
function __fitch_get_os
	switch $__fitch_kernel_name
		case "Linux" "GNU*"
			set -g __fitch_os "Linux"
		case "*BSD" "DragonFly" "Bitrig"
			set -g __fitch_os "BSD"
		case "CYGWIN*" "MSYS*" "MINGW*"
			set -g __fitch_os "Windows"
		case "SunOS"
			set -g __fitch_os "Solaris"
		case "Darwin"
			set -g __fitch_os "MacOS"
		case "Haiku"
			set -g __fitch_os "Haiku"
		case "MINIX"
			set -g __fitch_os "MINIX"
		case "AIX"
			set -g __fitch_os "AIX"
		case "IRIX*"
			set -g __fitch_os "IRIX"
		case "FreeMiNT"
			set -g __fitch_os "FreeMiNT"
		case "*"
			printf "%s\n" "Unknown/unsupported OS detected: $__fitch_kernel_name, aborting..."
			exit 1
	end
end

function __fitch_get_distro
	switch $__fitch_os
		case "Linux" "BSD" "MINIX"
			if test -f /bedrock/etc/bedrock-release && contains /bedrock/cross/* $PATH
				set -g __fitch_distro "Bedrock Linux"
			else if test -f /etc/redstar-release
				set -g __fitch_distro "Red Star OS"
			else if test -f /etc/armbian-release
				set -g __fitch_distro "Armbian"
			else if test -f /etc/siduction-version
				set -g __fitch_distro "Siduction"
			else if type -q lsb_release
				set -g __fitch_distro (lsb_release -sd)
	end
end
