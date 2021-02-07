#include <libnotify/notify.h>
#include <iostream>

//Namespaces
using std::cout;
using std::cerr;
using std::endl;
using std::string;

void callback_update_kernel() {
  cout << "Updating Kernel" << endl;
  system("workDir=$(pwd) $(pwd)/actions --display");
  system("pkexec kernel-notify -aa");
}
void callback_mute() {
  cout << "Muting Program" << endl;
  system("pkexec kernel-notify -am");
}

int main(int argc, char * argv[] ) {
  GMainLoop *loop;
  loop = g_main_loop_new(nullptr, FALSE);
  notify_init("Kernel Updater");
  NotifyNotification* n = notify_notification_new(argv[1], argv[2], argv[3]);

  //Check arguments 4-6 for keywords
  for (int i = 4; i <= 6; i++) {
    if (argc > i) {
      //Add callback action to update kernel
      if (argv[i] == string("kernel")) {
        notify_notification_add_action (n,
          "action_update",
          "Update Kernel",
           NOTIFY_ACTION_CALLBACK(callback_update_kernel),
           NULL,
           NULL);
      //Add callback action to mute program
      } else if (argv[i] == string("mute")) {
        notify_notification_add_action (n,
          "action_mute",
          "Mute",
           NOTIFY_ACTION_CALLBACK(callback_mute),
           NULL,
           NULL);
      //Set notification priority to critical
      } else if (argv[i] == string("critical")) {
        notify_notification_set_urgency(n, NOTIFY_URGENCY_CRITICAL);
      //Set notification priority to low
      } else if (argv[i] == string("low")) {
        notify_notification_set_urgency(n, NOTIFY_URGENCY_LOW);
      }
    }
  }

  notify_notification_set_hint (n, "desktop-entry", g_variant_new_string ("kernel-notify"));
  notify_notification_set_timeout(n, NOTIFY_EXPIRES_NEVER);
  if (!notify_notification_show(n, 0)) {
    cerr << "Notification failed" << endl;
    return 1;
  }

  while(notify_notification_get_closed_reason(n) == -1) {
    g_main_context_iteration(g_main_loop_get_context(loop), TRUE);
  }
  cerr << "Closed" << endl;

  g_main_loop_quit(loop);
  g_main_loop_unref(loop);
  notify_uninit();
  return 0;
}
