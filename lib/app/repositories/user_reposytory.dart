import 'package:mysql1/mysql1.dart';
import 'package:vakinha_burger_api/app/core/database/database.dart';
import 'package:vakinha_burger_api/app/core/exceptions/email_already_registered.dart';
import 'package:vakinha_burger_api/app/core/exceptions/user_notfound_excepition.dart';
import 'package:vakinha_burger_api/app/core/helpers/cripty_helper.dart';
import 'package:vakinha_burger_api/app/entities/user.dart';

class UserReposytory {
  //método de login
  Future<User> login(String email, String password) async {
    MySqlConnection? conn;
    try {
      conn = await Database().openConnection();
      final result = await conn.query(''' 
        select * from z_usuario 
        where email = ? 
        and senha = ? 
         ''', [email, CriptyHelper.generatedSha256Hash(password)]);

      if (result.isEmpty) {
        //não encontrou o usuario
        throw UserNotfoundExcepition();
      }
      //encontrou
      final userData = result.first;

      //o que vai retornar
      return User(
        id: userData['id'],
        name: userData['nome'],
        email: userData['email'],
        password: '',
      );
    } on MySqlException catch (e, s) {
      print(e);
      print(s);
      throw Exception('Erro ao realizar o login');
    } finally {
      await conn?.close();
    }
  }

  //método de inclusão
  Future<void> save(User user) async {
    MySqlConnection? conn;
    try {
      conn = await Database().openConnection();

      final isUserRegiser = await conn
          .query('select * from z_usuario where email = ? ', [user.email]);

      if (isUserRegiser.isEmpty) {
        await conn.query(''' 
        insert into z_usuario
        values(?,?,?,?)
        ''', [
          null,
          user.name,
          user.email,
          CriptyHelper.generatedSha256Hash(user.password)
        ]);
      } else {
        throw EmailAlreadyRegistered();
      }
    } on MySqlException catch (e, s) {
      print(e);
      print(s);
      throw Exception();
    } finally {
      await conn?.close();
    }
  }
}
