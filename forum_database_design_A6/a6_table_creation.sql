BEGIN TRANSACTION;

CREATE TABLE "Category" (
    "CategoryID"          SERIAL  NOT NULL PRIMARY KEY,
    "CategoryName"        TEXT    NOT NULL UNIQUE,
    "CategoryDescription" TEXT    NOT NULL DEFAULT ('') 
);

CREATE TABLE "User" (
    "UserID"          SERIAL    NOT NULL PRIMARY KEY,
    "DisplayName"     TEXT      NOT NULL,
    "Email"           TEXT      NOT NULL UNIQUE,
    "Password"        TEXT      NOT NULL,
    "IsBanned"        BOOLEAN   NOT NULL DEFAULT FALSE,
    "IsModerator"     BOOLEAN   NOT NULL DEFAULT FALSE,
    "IsAdministrator" BOOLEAN   NOT NULL DEFAULT FALSE,
    "RegisteredOn"    TIMESTAMP NOT NULL DEFAULT NOW(),
    "AvatarUrl"       TEXT
);

CREATE TABLE "Topic" (
    "TopicID"        SERIAL    PRIMARY KEY NOT NULL,
    "TopicName"      TEXT      NOT NULL,
    "AuthorUserID"   INTEGER   REFERENCES "User" ("UserID") ON DELETE SET NULL,
    "CategoryID"     INTEGER   REFERENCES "Category" ("CategoryID") ON DELETE RESTRICT,
    "IsPinned"       BOOLEAN   NOT NULL DEFAULT FALSE,
    "IsAnnouncement" BOOLEAN   NOT NULL DEFAULT FALSE,
    "CreatedOn"      TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK ("CategoryID" IS NOT NULL OR "IsAnnouncement" = TRUE) 
);

CREATE TABLE "Tags" (
	"TagID" SERIAL PRIMARY KEY NOT NULL,
	"TagName" TEXT NOT NULL UNIQUE
);

-- Storing which topics have which tags 
CREATE TABLE "TopicTags" (
	"TopicID" INT NOT NULL,
	"TagID" INT NOT NULL,
	PRIMARY KEY ("TopicID", "TagID")
);

CREATE TABLE "Posts" (
	"PostID" SERIAL PRIMARY KEY NOT NULL,
	"Post" TEXT NOT NULL,
	"CreatedOn" TIMESTAMP NOT NULL DEFAULT NOW(),
	"TopicID" INT NOT NULL REFERENCES "Topic" ("TopicID") ON DELETE CASCADE,
	"AuthorID" INT REFERENCES "User" ("UserID") ON DELETE SET NULL,
	"ReferenceID" INT REFERENCES "Posts" ("PostID") ON DELETE CASCADE,
	"IsUpdate" BOOLEAN NOT NULL DEFAULT FALSE,
	"TotalRatings" INT NOT NULL DEFAULT 0, --would do this with a trigger?
	CHECK ("TopicID" IS NOT NULL OR "IsUpdate" = TRUE OR "TotalRatings" >= 0)
);

CREATE TABLE "Ratings" (
	"PostID" INT NOT NULL REFERENCES "Posts" ("PostID") ON DELETE CASCADE,
	"RaterUserID" INT NOT NULL REFERENCES "User" ("UserID") ON DELETE CASCADE,
	"Rating" INT DEFAULT 0,
	CHECK("Rating" IN (-1, 0, 1)),
	PRIMARY KEY ("PostID", "RaterUserID")
);

CREATE TABLE "UserActivityLog" (
	"UserID" INT NOT NULL REFERENCES "User" ("UserID") ON DELETE CASCADE,
	"TopicID" INT NOT NULL REFERENCES "Topic" ("TopicID") ON DELETE CASCADE,
	"LastViewed" TIMESTAMP NOT NULL DEFAULT NOW(),
	PRIMARY KEY ("UserID", "TopicID")
);

CREATE TABLE "WatchTopic" (
	"TopicID" INT NOT NULL REFERENCES "Topic" ("TopicID") ON DELETE CASCADE,
	"UserID" INT NOT NULL REFERENCES "User" ("UserID") ON DELETE CASCADE,
	"WatchStart" TIMESTAMP NOT NULL DEFAULT NOW(),
	"IsUpdate" BOOLEAN NOT NULL DEFAULT FALSE,
	PRIMARY KEY ("TopicID", "UserID")
);

CREATE TABLE "WatchPost" (
	"PostID" INT NOT NULL REFERENCES "Posts" ("PostID") ON DELETE CASCADE,
	"UserID" INT NOT NULL REFERENCES "User" ("UserID") ON DELETE CASCADE,
	"WatchStart" TIMESTAMP NOT NULL DEFAULT NOW(),
	"IsUpdate" BOOLEAN NOT NULL DEFAULT FALSE,
	PRIMARY KEY ("PostID", "UserID")
);

COMMIT;