importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

// Gunakan konfigurasi web dari firebase_options.dart Anda
firebase.initializeApp({
  apiKey: "AIzaSyCvswf9ehMZrKWojI7iRC5Yl-XapDoCTTs",
  authDomain: "notes-1b051.firebaseapp.com",
  projectId: "notes-1b051",
  storageBucket: "notes-1b051.firebasestorage.app",
  messagingSenderId: "1052791010602",
  appId: "1:1052791010602:web:a18e520d7ef7f14efc9a53",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/favicon.png",
  };
  return self.registration.showNotification(notificationTitle, notificationOptions);
});
