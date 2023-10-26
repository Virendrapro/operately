import * as React from "react";
import * as Icons from "@tabler/icons-react";

import { Link } from "react-router-dom";

import * as Notifications from "@/models/notifications";

export default function Bell() {
  const count = Notifications.useUnreadCount();

  return (
    <Link
      to="/notifications"
      className="flex items-center gap-2 cursor-pointer relative group"
      data-test-id="notifications-bell"
    >
      <Icons.IconBell size={24} stroke={1.5} className="text-white-2 group-hover:text-white-1 transition-all" />
      <UnreadIndicator count={count} />
    </Link>
  );
}

function UnreadIndicator({ count }: { count: number }) {
  if (count === 0) return null;

  return (
    <div
      className="absolute -top-1 -right-1 rounded-full bg-orange-600 flex items-center justify-center text-white-1 leading-none group-hover:bg-orange-500 transition-all"
      style={{
        height: "17px",
        width: "17px",
        fontSize: "9px",
        fontWeight: "900",
      }}
      data-test-id="unread-notifications-count"
    >
      {count}
    </div>
  );
}