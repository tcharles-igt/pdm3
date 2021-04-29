import 'dart:io';

import 'package:lista_contatos/helpers/contact_helper.dart';
import 'package:lista_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> _contacts = List();

  void _getAllContacts(){
    helper.getAllContacts().then((list){
      setState(() {
        _contacts = list;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAllContacts();
  }

  Widget _contactCard(BuildContext context, int index){
    var contact = _contacts[index];

    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contact.img != null ?
                      FileImage(File(contact.img)) :
                      AssetImage("images/person.png"),
                      fit: BoxFit.cover
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contact.name ?? "",
                      style: TextStyle(fontSize: 22.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(contact.email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(contact.phone ?? "",
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){
        _showOptions(context, contact);
      },
    );
  }

  void _showOptions(BuildContext context, Contact contact){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return BottomSheet(
            builder: (context){
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlatButton(
                      child: Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: (){
                        launch("tel:${contact.phone}");
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: (){
                        Navigator.pop(context);
                        _showContactPage(contact: contact);
                      },
                    ),
                    FlatButton(
                      child: Text("Remover", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: (){
                        helper.deleteContact(contact.id).then((value){
                          Navigator.pop(context);
                          _getAllContacts();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
            onClosing: (){},
          );
        }
    );
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact,))
    );
    if(recContact != null){
      if(contact != null){
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        onPressed: (){
          _showContactPage();
        },
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: _contacts.length+1,
          itemBuilder: (context, index){
            return index == 0 ? _searshBar() : _contactCard(context, index-1);
          }
      ),
    );
  }

  _searshBar(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
            hintText: 'Pesquisar...'
        ),
        onChanged: (text){
          text = text.toLowerCase();
          if(text.isEmpty){
            _getAllContacts();
          }else{
            helper.searchContact(text).then((list){
              setState(() {
                _contacts = list;
              });
            });
          }
        },
      ),
    );
  }

}