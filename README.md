# Web Technologies Project @ PoliMi, 2025

---

<p align="center">
Vlad Raileanu
(<a href="https://github.com/rokuban">@rokuban</a>)
·
Vittorio Robecchi
(<a href="https://github.com/VictuarVi">@victuarvi</a>)
</p>

---

## MariaDB configuration

Start MariaDB:

```shell
sudo systemctl start mariadb
```

Then create the database:

```shell
sudo mariadb
CREATE DATABASE tiw;
# add privilegies
GRANT ALL PRIVILEGIES ON *.* TO `user`@'hostname';
exit;
```

And finally load execute the SQL file.

```shell
cd src/main/resources
mariadb --user NAME --password < tables.sql
```

where `NAME` = user from the step before.
