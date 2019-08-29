#include <libnotify/notify.h>
#include <iostream>

void callback_update_program(NotifyNotification* n, char* action, gpointer user_data) {
  std::cout << "Updating Program" << std::endl;
  system("kernel-notify -au");
}
void callback_update_kernel(NotifyNotification* n, char* action, gpointer user_data) {
  std::cout << "Updating Kernel" << std::endl;
  system("kernel-notify -aa");
}
void callback_mute(NotifyNotification* n, char* action, gpointer user_data) {
  std::cout << "Muting Program" << std::endl;
  system("kernel-notify -am");
}

int main(int argc, char * argv[] ) {
    GError *error = NULL;
    notify_init("Basics");
    NotifyNotification* n = notify_notification_new (argv[1],
                                 argv[2],
                                 argv[3]);

    if (argv[4] == std::string("program")) {
      notify_notification_add_action (n,
        "action_click",
        "Update Program",
         NOTIFY_ACTION_CALLBACK(callback_update_program),
         NULL,
         NULL);
    } else if (argv[4] == std::string("kernel")){
      notify_notification_add_action (n,
        "action_click",
        "Update Kernel",
         NOTIFY_ACTION_CALLBACK(callback_update_kernel),
         NULL,
         NULL);
    }

    if (argv[5] == std::string("mute")) {
      notify_notification_add_action (n,
        "action_click",
        "Mute",
         NOTIFY_ACTION_CALLBACK(callback_mute),
         NULL,
         NULL);
    }

    notify_notification_set_timeout(n, 10000);
    if (!notify_notification_show(n, 0)) 
    {
        std::cerr << "Notification failed" << std::endl;
        return 1;
    }
    return 0;
}
