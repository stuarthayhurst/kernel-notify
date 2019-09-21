#include <libnotify/notify.h>
#include <gtk/gtk.h>
#include <iostream>

int action_triggered = 0;

void callback_update_program(NotifyNotification* n, char* action, gpointer user_data) {
  std::cout << "Updating Program" << std::endl;
  action_triggered = 1;
  system("pkexec kernel-notify -au");
}
void callback_update_kernel(NotifyNotification* n, char* action, gpointer user_data) {
  std::cout << "Updating Kernel" << std::endl;
  action_triggered = 1;
  system("pkexec kernel-notify -aa");
}
void callback_mute(NotifyNotification* n, char* action, gpointer user_data) {
  std::cout << "Muting Program" << std::endl;
  action_triggered = 1;
  system("pkexec kernel-notify -am");
}

int main(int argc, char * argv[] ) {
    GError *error = NULL;
    gtk_init(&argc, &argv);
    notify_init("Basics");
    NotifyNotification* n = notify_notification_new(argv[1], argv[2], argv[3]);

    if (argv[4] == std::string("program")) {
      notify_notification_set_urgency(n, NOTIFY_URGENCY_CRITICAL);
      notify_notification_add_action (n,
        "action_update",
        "Update Program",
         NOTIFY_ACTION_CALLBACK(callback_update_program),
         NULL,
         NULL);
    } else if (argv[4] == std::string("kernel")){
      notify_notification_set_urgency(n, NOTIFY_URGENCY_CRITICAL);
      notify_notification_add_action (n,
        "action_update",
        "Update Kernel",
         NOTIFY_ACTION_CALLBACK(callback_update_kernel),
         NULL,
         NULL);
    }

    if (argv[5] == std::string("mute")) {
      notify_notification_add_action (n,
        "action_mute",
        "Mute",
         NOTIFY_ACTION_CALLBACK(callback_mute),
         NULL,
         NULL);
    } else {
      action_triggered = 1;
    }
    notify_notification_set_timeout(n, NOTIFY_EXPIRES_NEVER);
    if (!notify_notification_show(n, 0)) {
        std::cerr << "Notification failed" << std::endl;
        return 1;
    }
    while(action_triggered != 1) {
      if(notify_notification_get_closed_reason(n) != -1) {
        std::cerr << "Closed" << std::endl;
        action_triggered = 1;
      }
      gtk_main_iteration_do(FALSE);
    }
    g_object_unref(G_OBJECT(n));
    notify_uninit();
    return 0;
}
