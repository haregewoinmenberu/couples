CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "fullName" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phoneNumber" TEXT NOT NULL,
    "countryCode" TEXT NOT NULL DEFAULT '+1',
    "avatarSeed" TEXT NOT NULL DEFAULT '0',
    "phoneVerified" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "couples" (
    "id" TEXT NOT NULL,
    "userAId" TEXT NOT NULL,
    "userBId" TEXT NOT NULL,
    "anniversaryDate" TIMESTAMP(3) NOT NULL,
    "connectedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "couples_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "songs" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "artist" TEXT NOT NULL,
    "album" TEXT NOT NULL,
    "durationSecs" INTEGER NOT NULL,
    "artworkSeed" INTEGER NOT NULL DEFAULT 0,
    "moods" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "genres" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "isEthiopian" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "songs_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "memories" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "location" TEXT,
    "reactions" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "createdByUserId" TEXT NOT NULL,
    "coupleId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "memories_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "memory_photos" (
    "id" TEXT NOT NULL,
    "memoryId" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "memory_photos_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "memory_songs" (
    "memoryId" TEXT NOT NULL,
    "songId" TEXT NOT NULL,
    CONSTRAINT "memory_songs_pkey" PRIMARY KEY ("memoryId","songId")
);

CREATE TABLE "memory_comments" (
    "id" TEXT NOT NULL,
    "memoryId" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "memory_comments_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "dedications" (
    "id" TEXT NOT NULL,
    "fromUserId" TEXT NOT NULL,
    "songId" TEXT NOT NULL,
    "coupleId" TEXT,
    "type" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "photoSeed" INTEGER,
    "scheduledFor" TIMESTAMP(3),
    "delivered" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "dedications_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "chat_messages" (
    "id" TEXT NOT NULL,
    "coupleId" TEXT NOT NULL,
    "senderId" TEXT NOT NULL,
    "text" TEXT,
    "songId" TEXT,
    "imageUrl" TEXT,
    "type" TEXT NOT NULL DEFAULT 'text',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "chat_messages_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "playlists" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "coupleId" TEXT,
    "createdById" TEXT NOT NULL,
    "isShared" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "playlists_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "playlist_items" (
    "id" TEXT NOT NULL,
    "playlistId" TEXT NOT NULL,
    "songId" TEXT NOT NULL,
    "addedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "playlist_items_pkey" PRIMARY KEY ("id")
);

-- Unique indexes
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");
CREATE UNIQUE INDEX "users_phoneNumber_key" ON "users"("phoneNumber");
CREATE UNIQUE INDEX "couples_userAId_key" ON "couples"("userAId");
CREATE UNIQUE INDEX "couples_userBId_key" ON "couples"("userBId");
CREATE UNIQUE INDEX "playlist_items_playlistId_songId_key" ON "playlist_items"("playlistId","songId");

-- Foreign keys
ALTER TABLE "couples" ADD CONSTRAINT "couples_userAId_fkey" FOREIGN KEY ("userAId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "couples" ADD CONSTRAINT "couples_userBId_fkey" FOREIGN KEY ("userBId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "memories" ADD CONSTRAINT "memories_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "memories" ADD CONSTRAINT "memories_coupleId_fkey" FOREIGN KEY ("coupleId") REFERENCES "couples"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "memory_photos" ADD CONSTRAINT "memory_photos_memoryId_fkey" FOREIGN KEY ("memoryId") REFERENCES "memories"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "memory_songs" ADD CONSTRAINT "memory_songs_memoryId_fkey" FOREIGN KEY ("memoryId") REFERENCES "memories"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "memory_songs" ADD CONSTRAINT "memory_songs_songId_fkey" FOREIGN KEY ("songId") REFERENCES "songs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "memory_comments" ADD CONSTRAINT "memory_comments_memoryId_fkey" FOREIGN KEY ("memoryId") REFERENCES "memories"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "dedications" ADD CONSTRAINT "dedications_fromUserId_fkey" FOREIGN KEY ("fromUserId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "dedications" ADD CONSTRAINT "dedications_songId_fkey" FOREIGN KEY ("songId") REFERENCES "songs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "dedications" ADD CONSTRAINT "dedications_coupleId_fkey" FOREIGN KEY ("coupleId") REFERENCES "couples"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "chat_messages" ADD CONSTRAINT "chat_messages_coupleId_fkey" FOREIGN KEY ("coupleId") REFERENCES "couples"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "chat_messages" ADD CONSTRAINT "chat_messages_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "playlists" ADD CONSTRAINT "playlists_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "playlists" ADD CONSTRAINT "playlists_coupleId_fkey" FOREIGN KEY ("coupleId") REFERENCES "couples"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "playlist_items" ADD CONSTRAINT "playlist_items_playlistId_fkey" FOREIGN KEY ("playlistId") REFERENCES "playlists"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "playlist_items" ADD CONSTRAINT "playlist_items_songId_fkey" FOREIGN KEY ("songId") REFERENCES "songs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
