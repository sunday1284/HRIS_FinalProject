let stompClient;
const senderId = sessionStorage.getItem("currentUserId"); // 현재 로그인한 유저 ID

function connectChatRoom() {
  const socket = new SockJS("/wss");
  stompClient = Stomp.over(socket);

  stompClient.connect({}, function (frame) {
    console.log("🟢 채팅방 연결됨:", frame);

    stompClient.subscribe(`/topic/chat/${roomId}`, function (message) {
      const chat = JSON.parse(message.body);
      console.log("받은 메시지:", chat);
      showMessage(chat, true);
    });
  });
}

function sendMessage() {
  const content = $("#chatInput").val();
  if (!content || !senderId) return;

  const msg = {
    roomId,
    senderId,
    messageText: content
  };

  stompClient.send("/app/chat.send", {}, JSON.stringify(msg));
  $("#chatInput").val("");
}

function showMessage(chat, notify = false) {
  const isMine = chat.senderId === senderId;
  const openRoomId = sessionStorage.getItem("openRoomId");

  // 알림
  if (notify && !isMine && Notification.permission === "granted") {
    if (String(chat.roomId) !== openRoomId) {
      new Notification(`${chat.senderName}님`, {
        body: chat.messageText,
        icon: "https://cdn-icons-png.flaticon.com/512/3588/3588530.png"
      });
    }
  }

  const sentTime = chat.sentAt
    ? new Date(chat.sentAt).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
    : "";

  let messageBody = "";

  if (chat.chatFile && chat.fileDetail) {
    const file = chat.fileDetail;
    const downloadUrl = `/messenger/downloadFile?fileId=${file.detailId}`;
    const sizeText = file.fileSize < 1024 * 1024
      ? (file.fileSize / 1024).toFixed(1) + " KB"
      : (file.fileSize / (1024 * 1024)).toFixed(1) + " MB";

    messageBody = `
      <div class="file-card">
        <div class="file-icon">📄</div>
        <div class="file-info">
          <div class="file-name">${file.fileName}</div>
          <div class="file-size">${sizeText}</div>
        </div>
        <a href="${downloadUrl}" class="file-download" target="_blank">다운로드</a>
      </div>
    `;
  } else {
    messageBody = `<strong>${chat.senderName}</strong>: ${chat.messageText}`;
  }

  const messageHtml = `
    <div class="chat-message ${isMine ? 'mine' : 'other'}">
      <div class="chat-bubble">
        ${messageBody}
        <div class="chat-time">${sentTime}</div>
      </div>
    </div>
  `;

  $("#chat-box").append(messageHtml).scrollTop($("#chat-box")[0].scrollHeight);

  if (!isMine) {
    readMessage(chat.messageId, senderId);
  }
}

function loadPreviousMessages() {
  $.ajax({
    url: "/messenger/messages",
    type: "GET",
    data: { roomId: Number(roomId) },
    success: function (messages) {
      messages.forEach(msg => showMessage(msg, false));
    },
    error: function () {
      alert("이전 메시지를 불러오는 데 실패했습니다.");
    }
  });
}

function readMessage(messageId, empId) {
  $.ajax({
    url: "/messenger/message/read",
    type: "POST",
    data: { messageId, empId }
  });
}

function requestNotificationPermission() {
  if (!("Notification" in window)) {
    alert("이 브라우저는 알림을 지원하지 않아요.");
    return;
  }

  if (Notification.permission === "default") {
    Notification.requestPermission().then(permission => {
      if (permission === "granted") {
        console.log("알림 권한 허용됨");
      }
    });
  }
}

function uploadFileOnly() {
  const fileInput = document.querySelector("#fileInput");
  const file = fileInput.files[0];

  if (!file) {
    alert("업로드할 파일을 선택하세요");
    return;
  }

  uploadFile(file);
  fileInput.value = "";
}

function uploadFile(file) {
  const formData = new FormData();
  formData.append("file", file);
  formData.append("roomId", roomId);
  formData.append("senderId", senderId);

  fetch("/messenger/uploadFile", {
    method: "POST",
    body: formData
  })
    .then(resp => {
      if (!resp.ok) throw new Error("파일 업로드 실패");
      return resp.text();
    })
    .then(() => {
      console.log("업로드 완료");
      loadMessagesAfterUpload();
    })
    .catch(err => {
      console.error("업로드 에러:", err);
    });
}
function loadMessagesAfterUpload() {
  $.ajax({
    url: "/messenger/messages",
    type: "GET",
    data: { roomId: Number(roomId) },
    success: function (messages) {
      const latest = messages[messages.length - 1];
      if (latest) showMessage(latest, true);
    }
  });
}

$(document).ready(function () {
  sessionStorage.setItem("openRoomId", String(roomId));

  requestNotificationPermission();
  connectChatRoom();
  loadPreviousMessages();

  $("#sendBtn").on("click", sendMessage);
  $("#chatInput").on("keypress", e => { if (e.which === 13) sendMessage(); });
  $("#uploadFileBtn").on("click", uploadFileOnly);
  $("#closeBtn").on("click", () => {
    sessionStorage.removeItem("openRoomId");
    window.close();
  });

  // 창 닫기 이벤트
  window.addEventListener("beforeunload", () => {
    sessionStorage.removeItem("openRoomId");
  });

  // 드래그 앤 드롭 이벤트 처리
  const dropZone = document.getElementById("dropZone");

  if (dropZone) {
    dropZone.addEventListener("dragover", e => {
      e.preventDefault();
      dropZone.classList.add("dragover");
    });

    dropZone.addEventListener("dragleave", () => {
      dropZone.classList.remove("dragover");
    });

    dropZone.addEventListener("drop", e => {
      e.preventDefault();
      dropZone.classList.remove("dragover");

      const files = e.dataTransfer.files;
      if (files.length > 0) {
        uploadFile(files[0]);
      }
    });
  }
});
