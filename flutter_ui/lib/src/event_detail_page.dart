import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'helpers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventDetailPage extends StatefulWidget {
  final dynamic event;
  final refreshFollowing;

  const EventDetailPage(
      {super.key, required this.event, this.refreshFollowing});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  Color _colorFollow = Colors.white;
  bool following = false;
  bool _isLoading = true;

  Future<http.Response> _updateFollowing() async {
    following = !following;
    String host = widget.event['host'];

    String uri = "${Helpers.getUri()}/";
    if (following) {
      uri += "/following";
    } else {
      uri += "/unfollow";
    }

    final headers = {'Content-Type': 'application/json'};
    final bodyData = jsonEncode(<String, String>{'host': host});

    final response =
        await http.post(Uri.parse(uri), headers: headers, body: bodyData);

    if (response.statusCode == 200) {
      // refresh listing
      widget.refreshFollowing();
      return response;
    } else {
      throw Exception("error updating following for ${host}");
    }
  }

  void _loadEvent() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      // get currently logged in user (use default 'cpreciad')
      String uri = "${Helpers.getUri()}/followingHosts";
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode != 200) {
        print('Error: ${response.statusCode}');
      }
      // check if the current event is followed by user
      else {
        if (mounted) {
          var hosts = response.body;
          setState(() {
            if (hosts.contains(widget.event['host'])) {
              _colorFollow = Colors.blue;
              following = true;
            } else {
              _colorFollow = Colors.white;
              following = false;
            }
          });
        }
      }
    } catch (err) {
      print("Error loading event: ${err}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C2340),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 15.0, right: 15.0, bottom: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text(widget.event['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                )),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.grey[400],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200]!,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(7.5),
                                      bottomLeft: Radius.circular(7.5),
                                      topRight: Radius.circular(7.5),
                                      bottomRight: Radius.circular(7.5),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.group,
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    widget.event['host'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                OutlinedButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          side: const BorderSide(
                                              color: Color(0xFF0C2340)),
                                        ),
                                      ),
                                      backgroundColor:
                                          MaterialStatePropertyAll<Color>(
                                              _colorFollow)),
                                  onPressed: () {
                                    _updateFollowing();
                                    const snackBar = SnackBar(
                                      content: Text(
                                          'Successfully updating following hosts'),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    setState(() {
                                      _colorFollow =
                                          (_colorFollow == Colors.white)
                                              ? Colors.blue
                                              : Colors.white;
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.5,
                                      vertical: 0.0,
                                    ),
                                    child: Text(
                                      'Follow',
                                      style:
                                          TextStyle(color: Color(0xFF0C2340)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.grey[400],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200]!,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(7.5),
                                      bottomLeft: Radius.circular(7.5),
                                      topRight: Radius.circular(7.5),
                                      bottomRight: Radius.circular(7.5),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.event['startTime']!.day.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24.0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat.yMMMMd()
                                          .format(widget.event['startTime']!),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${DateFormat('h:mm a').format(widget.event['startTime'])} - ${DateFormat('h:mm a').format(widget.event['endTime'])}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18.0,
                                        color: Colors.grey[600],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.grey[400],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200]!,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(7.5),
                                      bottomLeft: Radius.circular(7.5),
                                      topRight: Radius.circular(7.5),
                                      bottomRight: Radius.circular(7.5),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.location_on,
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  widget.event['location']!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.grey[400],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.event['description'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16.0,
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          (widget.event['registrationLink'] == null ||
                  widget.event['registrationLink'] == "")
              ? const SizedBox()
              : TextButton(
                  onPressed: () {
                    launchURL(widget.event['registrationLink']);
                  },
                  child: Container(
                    height: 60.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.5),
                      color: const Color(0xFF0C2340),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'RSVP',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18.0,
                              color: Colors.white,
                              letterSpacing: 1.25,
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Icon(
                            Icons.open_in_browser,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  void launchURL(String link) async {
    final Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
