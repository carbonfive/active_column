## Data Migrations

The very first thing I would like to say about ActiveColumn Cassandra data migration is that *I stole most of the code
for this from the Rails gem (in ActiveSupport)*.  I made the necessary changes to update a Cassandra database
instead of a relational DB.  These changes were sort of significant, but I just wanted to give credit where credit
is due.

With that out of the way, we can discuss how you would use ActiveColumn to perform data migrations.

### Creating keyspaces

First we will create our project's keyspaces.

1. Make sure your cassandra 0.7 (or above) server is running.

2. Make sure you have your _config/cassandra.yml_ file created.  The [README](../README.md) has an example of
this file.

The ActiveColumn gem gives you several rake tasks within the **ks:** namespace.  "ks" stands for keyspace, which is
the equivalent of a database in MySQL (or other relational dbs).  To see the available tasks, run this rake command:

<pre>
rake -T ks
</pre>

3. Create your databases with the **ks:create:all** rake task:

<pre>
rake ks:create:all
</pre>

Voila!  You have now successfully created your keyspaces.  Now let's generate some migration files.

### Creating and running migrations

4. ActiveColumn includes a generator to help you create blank migration files.  To create a new migration, run this
command:

<pre>
rails g active_column:migration NameOfYourMigration
</pre>

The name of the migration might be something like "CreateUsersColumnFamily".  After you run this command, you should see
a new file that is located here:

<pre>
ks/migrate/20101229183849_create_users_column_family.rb
</pre>

Note that the date stamp on the file will be different depending on when you create the migration.  The migration file
will look like this:

<pre>
class CreateUsersColumnFamily &lt; ActiveColumn::Migration

  def self.up

  end

  def self.down

  end

end
</pre>

5. Edit your new migration file to do what you want it to.  For this migration, it would probably wind up looking like
this:

<pre>
class CreateUsersColumnFamily &lt; ActiveColumn::Migration

  def self.up
    create_column_family :users
  end

  def self.down
    drop_column_family :users
  end

end
</pre>

6. Run the migrate rake task (for development):

<pre>
rake ks:migrate
</pre>

This will create the column family for your development environment.  But you also need it in your test environment.
For now, you have to do this like the following.  However, soon this will be updated to work more like ActiveRecord
migrations.

7. Run the migrate rake task (for test):

<pre>
RAILS_ENV=test rake ks:migrate
</pre>

And BAM!  You have your development and test keyspaces set up correctly.