# Database-Systems-Course-work
Some notable projects from the database systems course.
I view assignments 5, 6, and 8 are the most notable projects. All work was done using PostgreSQL in the database tool called DBeaver.

Assignemnt 5 is about identifying and normalizng relationships in a given csv file containing forum post data. Then after completing that the next step was to import the data from the file into a temporary table and then inserting that data into the tables that were created in the database earlier. This is all done using transactions.

Assignment 6 starts with a written descption of requirments desired for a forum post website's database. The design of the database goes through these following steps. Identifying the entities, attirbutes and identifiers in the written description. Then designing an Entity-Relationship model usiing Crow's Foot notation. Lastly all tables are then created and implemented with all necessary attribute constraints and checks included. This is done within a transaction.

Assignment 8 builds on the forum post database from before. Here python is used to implement requirments that were not possible using just the database managment system. Using the psycopg2 library these requirments are implemented and with a certain design ensuring the databases secruity and safety from injection attacks. Proper function documentation is the only thing missing from the python file. 

Course description and topics  

Students will develop competency in areas of data analytics, data modelling, and back-end engineering. Upon successful completion of this course, students will be able to:  
    - Explain the role and importance of databases in modern applications and within our society.  
    - Design and implement relational databases using conceptual and logical models.  
    - Write complex SQL queries to retrieve, manipulate, and transform data.  
    - Learn how to populate a relational database with data.  
    - Apply normalization techniques to optimize database design.  
    - Implement security measures to protect database integrity and availability.  
    - Integrate SQL with programming languages like Python for data-driven applications.  
    - Utilize indexing and performance tuning techniques to enhance database efficiency.  
    - Understand and manage transactions, concurrency, and data consistency.  
    - Explore non-relational databases and their use cases.  

Topics  
    - Introduction to Databases (and an overview of network and hierarchical models)    
    - The Relational Model (and an introduction to query languages, relational algebra, and relational calculus)  
    - Basic SQL SELECT Statements (involving single tables)  
    - Advanced SQL SELECT Statements (involving multiple tables)  
    - Conceptual Design and Entity-Relation Diagrams  
    - Functional Dependencies and Choosing Keys  
    - Database Normalization (up to BCNF)  
    - Constraints and Data Integrity  
    - Transforming Conceptual Designs into Logical and Physical Database Designs  
    - Database Security and Availability  
    - Transactions and ACID Compliance  
    - Extract, Transform, Load (populating a database with data)  
    - Embedding SQL into Python  
    - Database Performance: Indexes and EXPLAIN  
    - Advanced SELECT Queries: e.g., CTEs, Window Functions, JSON data, advanced aggregation  
    - Object-Relational Mapping (ORMs)  
    - Concurrency Control  
    - Introduction to Document-Oriented Databases  
 

