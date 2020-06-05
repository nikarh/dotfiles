#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libudev.h>
#include <unistd.h>
#include <getopt.h>
#include <ctype.h>
#include <sys/select.h>

int main(int argc, char **argv) 
{
	char* subsystem = NULL;
	char* command = NULL;
	int c;
	while ((c = getopt(argc, argv, "s:e:")) != -1)
		switch (c) {
			case 's':
				subsystem = optarg;
				break;
			case 'e':
				command = optarg;
				break;
			default:
				abort();
		}
		
	// Check mandatory parameters
	if (subsystem == NULL) {
		printf("You must provide a subsystem for subscription with -s argument!\n");
		return 1;
	}
	if (command == NULL) {
		printf("You must provide a comand to execute with -e argument!\n");
		return 1;
	}

	// create udev object 
	struct udev *udev = udev_new();
	if (!udev) {
		fprintf(stderr, "Cannot create udev context.\n");
		return 1;
	}

	fprintf(stderr, "Monitoring \"%s\" subsystem.\n", subsystem);

	struct udev_monitor *mon = udev_monitor_new_from_netlink(udev, "udev");
	udev_monitor_filter_add_match_subsystem_devtype(mon, subsystem, NULL);
	udev_monitor_enable_receiving(mon);

	int fd = udev_monitor_get_fd(mon);
	while (1) {
		fd_set fds;

		FD_ZERO(&fds);
		FD_SET(fd, &fds);

		int ret = select(fd+1, &fds, NULL, NULL, NULL);
		if (ret > 0 && FD_ISSET(fd, &fds)) {
			struct udev_device *dev = udev_monitor_receive_device(mon);
			if (dev) {
				struct udev_list_entry *list;
				struct udev_list_entry *first;

				list = udev_device_get_properties_list_entry(dev);
				first = list;

				// Set all device properties as ENV variables
				udev_list_entry_foreach(list, first) {
					setenv(
						udev_list_entry_get_name(list), 
						udev_list_entry_get_value(list),
						1);
				}
				
				// Execute our program
				system(command);

				// Clear ENV variables
				list = first;
				udev_list_entry_foreach(list, first) {
					unsetenv(udev_list_entry_get_name(list)); 
				}

				// free dev
				udev_device_unref(dev);
			}
		}
	}

	// free udev
	udev_unref(udev);

	return 0;
}
