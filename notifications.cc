#include <libnotify/notify.h>
#include <iostream>

int main(int argc, char * argv[] ) 
{
    GError *error = NULL;
    GdkPixbuf *icon;
    icon = gdk_pixbuf_new_from_file("/usr/share/kernel-notify/icon.png", &error);
    notify_init("Basics");
    NotifyNotification* n = notify_notification_new ("Hello world", 
                                 "some message text... bla bla",
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
