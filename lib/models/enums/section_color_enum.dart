import 'package:flutter/material.dart';

enum SectionColor {
  se(color: Colors.red),
  un(color: Color.fromRGBO(49, 157, 243, 1.0)),
  pl(color: Colors.green),
  mix(color: Colors.pink),
  imp(color: Colors.orange),
  al(color: Colors.purple),
  cag(color: Colors.blueAccent),
  can(color: Colors.blueAccent),
  fs(color: Colors.blueGrey),
  c(color: Colors.indigo), //Que es?
  esub(color: Colors.brown),
  edec(color: Colors.black26), //no aplica
  sif(color: Colors.yellow),
  def(color: Colors.black26); //color default

  const SectionColor({
    required this.color,
  });

  final Color color;
}
