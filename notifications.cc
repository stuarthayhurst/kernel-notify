#include <libnotify/notify.h>
#include <iostream>

int main(int argc, char * argv[] ) 
{
    GError *error = NULL;
    GdkPixbuf *icon;
    icon = gdk_pixbuf_new_from_file(argv[3], &error);
    notify_init("Basics");
    NotifyNotification* n = notify_notification_new (argv[1], 
                                 argv[2],
                                  0);
    notify_notification_set_icon_from_pixbuf
                                                            (n,
                                                              icon);
    notify_notification_set_timeout(n, 10000);

    if (!notify_notification_show(n, 0)) 
    {
        std::cerr << "Notification failed" << std::endl;
        return -1;
    }
    return 0;
}
