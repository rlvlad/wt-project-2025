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

# Usage

## MariaDB configuration

Start MariaDB:

```shell
sudo systemctl start mariadb
```

Then access MariaDB console:

```shell
sudo mariadb
```

and create the database:

```mariadb
CREATE DATABASE db_name;
# add privileges
GRANT ALL PRIVILEGES ON db_name.* TO `user`@'hostname';
exit;
```

And finally load the SQL file:

```shell
mariadb --user NAME --password < *.sql
```

where `NAME` = user from the step before.

# Tech stack 🖥️

- Typesetting: [typst](https://typst.app/)
- Diagrams: [draw.io](https://app.diagrams.net/) for ER, [yFiles](https://www.yworks.com/products/yfiles) for UML (integrated in IntelliJ) and [ifml editor](https://editor.ifmledit.org/) for IFML
- DBMS: [MariaDB](https://mariadb.org/)
- Java
    - IDE: JetBrains IntelliJ Idea Ultimate Edition ([website](https://www.jetbrains.com/idea/))
    - Java JDK: OpenJDK (`openjdk-24`, [website](https://openjdk.java.net/))
    - Build tool: [Apache Maven](https://maven.apache.org/)
    - Documentation: Javadoc
- Web development
    - Jakarta Servlet: [Apache Tomcat](https://tomcat.apache.org/)
    - Template engine: [Thymeleaf](https://www.thymeleaf.org/)
