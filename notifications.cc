#include <libnotify/notify.h>
#include <iostream>

int my_callback_func ()
{
  std::cout << "Test" << std::endl;
  return 0;
}

int main(int argc, char * argv[] ) 
{
    GError *error = NULL;
    notify_init("Basics");
    NotifyNotification* n = notify_notification_new (argv[1], 
                                 argv[2],
                                 argv[3]);
    //notify_notification_add_action (n,
    //    const char *action_click,
    //    const char *label,
    //    NotifyActionCallback my_callback_func);
    notify_notification_set_timeout(n, 10000);

    if (!notify_notification_show(n, 0)) 
    {
        std::cerr << "Notification failed" << std::endl;
        return -1;
    }
    return 0;
}
