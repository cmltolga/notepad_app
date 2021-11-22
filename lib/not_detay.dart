import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/main.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/models/notlar.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';
import 'dart:core';

import 'kategori_islemleri.dart';

class NotDetay extends StatefulWidget {
  String baslik;
  Notlar duzenlenecekNot;

  NotDetay({this.baslik, this.duzenlenecekNot});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  var formKey = GlobalKey<FormState>();
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;
  Kategori secilenKategori;
  int kategoriID = 1;
  int secilenOncelik;
  String notBaslik, notIcerik;
  static var _oncelik = ["düşük", "orta", "yüksek"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumKategoriler = List<Kategori>();
    databaseHelper = DatabaseHelper();
    databaseHelper.kategorileriGetir().then((kategoriMap) {
      for (Map okunanMap in kategoriMap) {
        tumKategoriler.add(Kategori.fromMap(okunanMap));
      }
      if (widget.duzenlenecekNot != null) {
        secilenOncelik = widget.duzenlenecekNot.notOncelik;
      } else {
        secilenOncelik = 0;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.baslik),
      ),
      body: tumKategoriler.length <= 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
            child: Container(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Kategori: ",
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                items: kategoriItems(),
                                value: secilenKategori,
                                onChanged: (Kategori kullanicininKategorisi) {
                                  setState(() {
                                    secilenKategori = kullanicininKategorisi;
                                    kategoriID = kullanicininKategorisi.kategoriID;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: widget.duzenlenecekNot != null ? widget.duzenlenecekNot.notBaslik : "",
                          // ignore: missing_return
                          validator: (text) {
                            if (text.length < 3) {
                              return "En az 3 karakter olamlı";
                            }
                          },
                          onSaved: (text) {
                            notBaslik = text;
                          },
                          decoration: InputDecoration(
                            hintText: "Not başlığını Giriniz",
                            labelText: "Başlık",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: widget.duzenlenecekNot != null ? widget.duzenlenecekNot.notIcerik : "",
                          onSaved: (text) {
                            notIcerik = text;
                          },
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: "Not içeriğini Giriniz",
                            labelText: "Not içeriğini Giriniz",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Öncelik: ",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                items: _oncelik.map((oncelik) {
                                  return DropdownMenuItem<int>(
                                    child: Text(
                                      oncelik,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    value: _oncelik.indexOf(oncelik),
                                  );
                                }).toList(),
                                value: secilenOncelik,
                                onChanged: (secilenOncelikID) {
                                  setState(() {
                                    secilenOncelik = secilenOncelikID;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                      ButtonBar(
                        children: [
                          RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Vazgeç",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.orange.shade300,
                          ),
                          RaisedButton(
                            onPressed: () {
                              if (formKey.currentState.validate()) {
                                formKey.currentState.save();
                                var suan = DateTime.now();
                                if (widget.duzenlenecekNot == null) {
                                  databaseHelper
                                      .notEkle(Notlar(kategoriID, notBaslik, notIcerik, suan.toString(), secilenOncelik))
                                      .then((kayitID) {
                                    if (kayitID != 0) {
                                      setState(() {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => NotListesi()));
                                      });
                                    }
                                  });
                                } else {
                                  databaseHelper
                                      .notGuncelle(Notlar.withID(widget.duzenlenecekNot.notID, kategoriID, notBaslik,
                                          notIcerik, suan.toString(), secilenOncelik))
                                      .then((guncelID) {
                                    if (guncelID != 0) {
                                      setState(() {
                                        databaseHelper.notListesi();
                                      });
                                    }
                                  });
                                }
                              }
                            },
                            child: Text(
                              "Kaydet",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.green.shade300,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ),
    );
  }

  List<DropdownMenuItem<Kategori>> kategoriItems() {
    return tumKategoriler.map((kategorim) {
      return DropdownMenuItem<Kategori>(
        value: kategorim,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            kategorim.kategoriBaslik,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }).toList();
  }
}
/*
* Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                child: DropdownButtonHideUnderline(
                  child: tumKategoriler.length<=0 ? CircularProgressIndicator() :
                  DropdownButton<Kategori>(
                    items: kategoriItems(),
                    value: secilenKategori,
                    onChanged: (Kategori kullanicininKategorisi) {
                      setState(() {
                        secilenKategori=kullanicininKategorisi;
                        kategoriID=kullanicininKategorisi.kategoriID;
                      });
                    },
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 4,horizontal: 24),
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent,width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      )
* */
