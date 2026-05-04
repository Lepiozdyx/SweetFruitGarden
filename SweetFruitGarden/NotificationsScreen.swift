import SwiftUI

struct NotificationsScreen: View {
    @EnvironmentObject private var store: GardenStore

    var body: some View {
        ZStack(alignment: .top) {
            RadialGradient(
                colors: [Color.hex("2D1060"), Color.hex("1A0A2E"), Color.hex("0D0518")],
                center: .top,
                startRadius: 20,
                endRadius: 900
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    Color.clear.frame(height: 68)
                    bannerCard
                    upcomingTitle
                    upcomingList
                    completedSection
                    settingsCard
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 92)
            }

            headerBar
        }
    }

    private var headerBar: some View {
        HStack {
            Text("Notifications")
                .font(.custom("Fredoka One", size: 20))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 56)
        .background(LinearGradient(colors: [Color.hex("2D1B4E"), Color.hex("241540")], startPoint: .top, endPoint: .bottom))
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
        }
    }

    private var bannerCard: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(store.activeReminders.count) Active Reminders 🔔")
                    .font(.custom("Fredoka One", size: 18))
                    .foregroundStyle(.white)
                Text("\(store.completedReminders.count) completed this season")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.8))
            }
            Spacer()
            Text("\(store.activeReminders.count)")
                .font(.custom("Fredoka One", size: 32))
                .foregroundStyle(Color.hex("FFD700"))
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .frame(height: 84.5)
        .background(
            LinearGradient(
                colors: [Color.hex("FF6B35"), Color.hex("FF1493"), Color.hex("7B00FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.hex("FF6B35").opacity(0.35), radius: 14, y: 8)
    }

    private var upcomingTitle: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.hex("FFD700"))
                .frame(width: 3, height: 16)
            Text("Upcoming")
                .font(.custom("Fredoka One", size: 16))
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private var upcomingList: some View {
        VStack(spacing: 10) {
            ForEach(store.activeReminders) { item in
                notificationCard(item: item)
            }
        }
    }

    private func notificationCard(item: ReminderItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "bell")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.hex("FFD700"))
                Text(formattedDateTime(item.eventDate))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hex("FFE066"))
                Spacer()
            }

            Text(item.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                actionButton(title: "SNOOZE", active: false, width: 108) {
                    store.snoozeReminder(item.id)
                }
                actionButton(title: "DONE", active: true, width: 108) {
                    store.markReminderDone(item.id)
                }
                actionButton(title: "SKIP", active: false, width: 75) {
                    store.skipReminder(item.id)
                }
            }
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 132)
        .background(LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
    }

    private func actionButton(title: String, active: Bool, width: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
        Text(title)
            .font(active ? .custom("Fredoka One", size: 12) : .system(size: 12, weight: .semibold))
            .tracking(0.8)
            .foregroundStyle(active ? Color.hex("3A2000") : Color.white.opacity(0.75))
            .frame(width: width, height: 36)
            .background(
                Group {
                    if active {
                        LinearGradient(
                            colors: [Color.hex("FFF0A0"), Color.hex("FFE040"), Color.hex("FFD700"), Color.hex("D4A800"), Color.hex("AA8000")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        Color.white.opacity(0.07)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: active ? 16 : 12)
                    .stroke(active ? Color.hex("FFF099").opacity(0.45) : Color.white.opacity(0.12), lineWidth: active ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: active ? 16 : 12))
            .shadow(color: active ? Color.hex("FFD700").opacity(0.55) : .black.opacity(0.2), radius: active ? 12 : 4, y: 3)
        }
    }

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.hex("FFD700").opacity(0.3))
                    .frame(width: 3, height: 16)
                Text("Completed")
                    .font(.custom("Fredoka One", size: 16))
                    .foregroundStyle(Color.white.opacity(0.5))
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "bell")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.hex("FFD700"))
                    Text(store.completedReminders.first.map { formattedDateTime($0.eventDate) } ?? "—")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.hex("FFE066"))
                    Spacer()
                    Text("Done ✓")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.hex("76FF03"))
                        .frame(width: 56, height: 22.5)
                        .background(Color.hex("76FF03").opacity(0.15))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.hex("76FF03").opacity(0.3), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Text(store.completedReminders.first?.title ?? "No completed reminders yet")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 100.5)
            .background(LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
            .opacity(0.55)
        }
        .frame(height: 134.5, alignment: .top)
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(LinearGradient(colors: [Color.hex("FF80D0"), Color.hex("CC1493")], startPoint: .top, endPoint: .bottom))
                    .frame(width: 3, height: 16)
                    .shadow(color: Color.hex("FF50B4").opacity(0.6), radius: 6)
                Text("Notification Settings")
                    .font(.custom("Fredoka One", size: 17))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Reminder time")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.6))
                HStack(spacing: 8) {
                    optionButton(title: "Morning", active: store.settings.reminderTime == .morning, width: 150) {
                        store.updateReminderTime(.morning)
                    }
                    optionButton(title: "Evening", active: store.settings.reminderTime == .evening, width: 150) {
                        store.updateReminderTime(.evening)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Remind me")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.6))
                HStack(spacing: 8) {
                    optionButton(title: "1 day before", active: store.settings.remindBeforeDays == .one, width: 97.33) {
                        store.updateLeadDays(.one)
                    }
                    optionButton(title: "3 days before", active: store.settings.remindBeforeDays == .three, width: 97.34) {
                        store.updateLeadDays(.three)
                    }
                    optionButton(title: "7 days before", active: store.settings.remindBeforeDays == .seven, width: 97.34) {
                        store.updateLeadDays(.seven)
                    }
                }
            }
        }
        .padding(.horizontal, 17)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 249.5)
        .background(LinearGradient(colors: [Color.hex("3D1248"), Color.hex("280A34"), Color.hex("1A0524")], startPoint: .topLeading, endPoint: .bottomTrailing))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.hex("FF50B4").opacity(0.1), lineWidth: 1.2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.4), radius: 14, y: 4)
    }

    private func optionButton(title: String, active: Bool, width: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(active ? .white : Color.white.opacity(0.55))
            .frame(width: width, height: 44)
            .background(
                Group {
                    if active {
                        LinearGradient(
                            colors: [Color.hex("FFBB7A"), Color.hex("FF8040"), Color.hex("FF6B35"), Color.hex("C84000")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        Color.white.opacity(0.07)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(active ? Color.hex("FFC896").opacity(0.4) : Color.white.opacity(0.12), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: active ? Color.hex("FF6B35").opacity(0.5) : .clear, radius: 8, y: 4)
        }
    }

    private func formattedDateTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy · HH:mm"
        return f.string(from: date)
    }
}

#Preview {
    NotificationsScreen()
        .environmentObject(GardenStore())
}
