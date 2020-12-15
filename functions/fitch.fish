set -g __fitch_os ""
set -g __fitch_title ""
set -g __fitch_distro ""

# Sets the kernel name, we'll need it.
set -g __fitch_kernel_name (uname -s)
set -g __fitch_kernel_version (uname -r)

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
		case "Linux"
			if type -q lsb_release
				set -g __fitch_distro (lsb_release -sd)
			# Android detection works by searching system apps.
			else if test -d /system/app && test -d /system/priv-app
				set -g __fitch_distro "Android " (getprop ro.build.version.release)
			else
				while IFS='=' read key val
					switch PRETTY_NAME
						case $key
							set -g __fitch_distro $val
					end 
				end < /etc/os-release
			end
			# /etc/os-release and lsb_release sometimes have quotes surrounding them
			set -g __fitch_distro (echo $__fitch_distro | sed 's/"//g')

			# ...independent distributions that don't follow release standards
			# almost forgot they existed
			if type -q crux
				set -g __fitch_distro (crux)
			else if type -q guix
				set -g __fitch_distro "Guix System"
			end

			# Check for Windows Subsystem for Linux,
			# WSL2 generally tends to use the $WSLENV variable,
			# whereas WSL1 tends to have a kernel that has the localversion of "-[windows-build-number]-Microsoft".
			if $WSLENV
				set -g __fitch_distro "$__fitch_distro ($WSLENV on Windows 10 [WSL2])"
			else if string match '*-Microsoft' $__fitch_kernel_version
				set -g __fitch_distro "$__fitch_distro on Windows 10 (WSL1)"
			end
			# Bedrock Linux is very well... unique...
			# Add some checks for that too.
			if contains */bedrock/cross/* $PATH
				set -g __fitch_distro "Bedrock Linux"
		case "Haiku"
			set -g __fitch_distro (uname -sv)
		case "Darwin"
			set -l macos_ver (sw_vers -productVersion)
			
			switch $macos_ver
				case "10.4" 
					set -g __fitch_distro "Mac OS X Tiger"
				case "10.5"
					set -g __fitch_distro "Mac OS X Leopard"
				case "10.6"
					set -g __fitch_distro "Mac OS X Snow Leopard"
				case "10.7"
					set -g __fitch_distro "Mac OS X Lion"
				case "10.8" 
					set -g __fitch_distro "OS X Mountain Lion"
				case "10.9"
					set -g __fitch_distro "OS X Mavericks"
				case "10.10"
					set -g __fitch_distro "OS X Yosemite"
				case "10.11"
					set -g __fitch_distro "OS X El Capitan"
				case "10.12"
					set -g __fitch_distro "macOS Sierra"
				case "10.13"
					set -g __fitch_distro "macOS High Sierra"
				case "10.14"
					set -g __fitch_distro "macOS Mojave"
				case "10.15"
					set -g __fitch_distro "macOS Catalina"
				case "11.1"
					set -g __fitch_distro "macOS Big Sur"
				case "*"
					set -g __fitch_distro "macOS"
			end
			
			set -g __fitch_distro "$__fitch_distro $macos_ver"
		case "Minix" "DragonFly"	
			set -g __fitch_distro "$__fitch_os $__fitch_kernel_version"
			
			# Minix and DragonFly don't support the normal escape
			# sequences used, so we clear the exit trap
			trap '' EXIT
		case "SunOS"
			IFS="(" read distro _ < /etc/release
	end
end
