
import psycopg2
import psycopg2.extras
from psycopg2.sql import *
import hashlib

conn = psycopg2.connect(host="localhost", database="A8", user="postgres", password="4987", port=5432)
cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)


# Insert a new category.
def insert_category(category_name: str, category_description: str = ""):
    cur.execute("""INSERT INTO "Category" (
                   "CategoryName", 
                   "CategoryDescription") 
                   VALUES (%s, %s)""", (category_name, category_description))
    conn.commit()


# Insert a new user.
def insert_user(display_name: str, email: str, password: str,
                is_banned: bool = False, is_moderator: bool = False, is_administrator: bool = False) -> None:
    insert_query = SQL("""
    INSERT INTO "User" (
      "DisplayName",
      "Email",
      "Password",
      "Salt",
      "IsBanned",
      "IsModerator",
      "IsAdministrator"
    ) VALUES (%s, %s, %s, '', {is_banned}, {is_moderator}, {is_administrator})""".format(
        is_banned="default" if is_banned is None else Literal(is_banned).as_string(conn),
        is_moderator="default" if is_moderator is None else Literal(is_moderator).as_string(conn),
        is_administrator="default" if is_administrator is None else Literal(is_administrator).as_string(conn)
    )).as_string(conn)

    cur.execute(insert_query, (
        display_name,
        email,
        password))
    conn.commit()
    

# Fetch all the columns for a single user row, by the PK.
def fetch_user_details(user_id: int) -> dict:
    cur.execute("""SELECT * FROM "User" WHERE "UserID" = %s""", (user_id,))
    return cur.fetchone()


# Question 1. Return the post_id if the post was successfully inserted, or False otherwise.
def insert_post(topic_id: int, user_id: int, post_content: str, parent_post_id: int = None) -> int:
    post_id = None

    # To do: INSERT
    # user is banned?
    cur.execute("""SELECT "IsBanned" FROM "User" WHERE "UserID" = %s""", (user_id,))
    user = fetch_user_details(user_id)
    
    if user["IsBanned"]:
        print("Error: User is banned and cannot post.")
        return False

    # Insert
    else:
        insert_query = SQL("""
        INSERT INTO "Post" (
            "TopicID", 
            "AuthorUserID", 
            "PostContent", 
            "ParentPostID"
        ) VALUES (%s, %s, %s, %s)
        RETURNING "PostID";""").as_string(conn)
        
        cur.execute(insert_query, (topic_id, user_id, post_content, parent_post_id))
        post_id = cur.fetchone()["PostID"]

        
        conn.commit()

        return post_id


# Question 2. Return the topic_id if the topic was successfully inserted, 
# or None otherwise.
def insert_topic(user_id: int, topic_name: str, post_content: str, 
                 category_id: int = None, is_pinned: bool = False) -> int:
    # To do: INSERT the topic
    cur.execute("""SELECT "IsBanned", "IsModerator", "IsAdministrator"
                       FROM "User" WHERE "UserID" = %s""", (user_id,))
    user = fetch_user_details(user_id)

    if user["IsBanned"]:
        print("Error: User is banned and cannot create topics.")
        return None

    elif is_pinned and not (user["IsModerator"] or user["IsAdministrator"]):
        print("Error: User lacks permissions to create pinned topics.")
        return None

    else:
        insert_query = SQL("""
        INSERT INTO "Topic" (
            "TopicName",
            "AuthorUserID",
            "CategoryID",
            "IsPinned"
        ) VALUES (%s, %s, %s, %s)
        RETURNING "TopicID";""").as_string(conn)
        
        cur.execute(insert_query, (topic_name, user_id, category_id, is_pinned))
        
        # To do: This needs to be set to the actual, new topic_id
        topic_id = cur.fetchone()["TopicID"]

        conn.commit()

        # To do: only insert the post if the topic was inserted successfully.
        insert_post(topic_id, user_id, post_content)

        return topic_id


# Question 3.
# rating will be one of three values: 0, 1, or -1
def rate_post(user_id: int, post_id: int, rating: int) -> None:
    # To do: INSERT or UPDATE.
    # checking if a rating exists
    cur.execute("""SELECT "RatingID" FROM "Rating" 
                   WHERE "PostID" = %s AND "RatedByUserID" = %s""", (post_id, user_id))
    existing_rating = cur.fetchone()

    if existing_rating:
        # update
        cur.execute("""UPDATE "Rating"
                       SET "Rating" = %s
                       WHERE "RatingID" = %s""",
                    (rating, existing_rating["RatingID"]))
    else:
        # insert
        cur.execute("""INSERT INTO "Rating" (
                       "PostID",
                       "RatedByUserID",
                       "Rating")
                       VALUES (%s, %s, %s)""", (post_id, user_id, rating))

    conn.commit()


# Question 4. Delete a Category by ID, replacing that CategoryID with a different CategoryID, for each Topic.
def delete_category(category_id: int, replace_with_category_id: int) -> None:
    # To do: UPDATE, then DELETE
    
    # Update
    cur.execute("""
            UPDATE "Topic"
            SET "CategoryID" = %s
            WHERE "CategoryID" = %s
        """, (replace_with_category_id, category_id))
        
    # Delete
    cur.execute("""
        DELETE FROM "Category"
        WHERE "CategoryID" = %s
    """, (category_id,))

    conn.commit()


# Used to demonstrate an SQL injection attack
def unsafe_function(user_id: int):
    cur.execute("""SELECT "UserID", "DisplayName" 
                   FROM "User" WHERE "UserID" = {};""".format(user_id))
    return cur.fetchall()


# Using the unsafe function to get the passwords.
def sql_injection_attack():
    print(unsafe_function("1 UNION SELECT \"UserID\", \"Password\" FROM \"User\""))


# tests

# insert_category("Big Nums", "I like big Nums and i cannot lie.")

# insert_user("Nums master", "ilikenums@numsauce.com", "secertnums09", False, True, True)
# insert_user("Nums assistant", "ilikenums2@numsauce.com", "secertnums19", False, False, True)
# insert_user("Nums teacher", "ilikenums3@numsauce.com", "secertnums29", False, True, False)
# insert_user("Nums student", "ilikenums4@numsauce.com", "secertnums39", False, False, False)
# insert_user("Nums traitor", "ilikenums5@numsauce.com", "secertnums49", True, False, False)

# insert_topic(1, "nums are the best", "nums are the best cause...", 1, True)
# insert_topic(2, "nums are the bestish", "nums are the bestish cause...", 1, True)
# insert_topic(3, "nums are the good", "nums are the good cause...", 1, True)
# insert_topic(4, "nums are the ok", "nums are the ok cause...", 1, True)
# insert_topic(4, "nums are the ok", "nums are the ok cause...", 1, False)
# insert_topic(5, "nums are the worst", "nums are the worst cause...", 1, False)

# insert_post(1, 4, "Content...", 1)
# insert_post(1, 5, "Contents...", 1)

# rate_post(4, 5, 1)
# rate_post(4, 5, -1)

# insert_category("Better Big Nums", "I like better big Nums and I cannot lie.")

# delete_category(1, 3)
