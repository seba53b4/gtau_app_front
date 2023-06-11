import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

List<Map<String, dynamic>> mockLines = [
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13955,
          -34.88773
        ],
        [
          -56.139545,
          -34.88773
        ],
        [
          -56.139362,
          -34.88766
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.139893,
          -34.88784
        ],
        [
          -56.13959,
          -34.887726
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13959,
          -34.887726
        ],
        [
          -56.13959,
          -34.887722
        ],
        [
          -56.13955,
          -34.88773
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138203,
          -34.887203
        ],
        [
          -56.13773,
          -34.887012
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13773,
          -34.887012
        ],
        [
          -56.137672,
          -34.886963
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.139362,
          -34.88766
        ],
        [
          -56.13875,
          -34.88739
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13875,
          -34.88739
        ],
        [
          -56.138203,
          -34.887203
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.14006,
          -34.886517
        ],
        [
          -56.13932,
          -34.886494
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13932,
          -34.886494
        ],
        [
          -56.138657,
          -34.88647
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.139175,
          -34.88568
        ],
        [
          -56.13948,
          -34.88546
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13906,
          -34.88576
        ],
        [
          -56.13895,
          -34.885666
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13895,
          -34.885666
        ],
        [
          -56.138256,
          -34.885094
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138657,
          -34.88647
        ],
        [
          -56.138496,
          -34.88618
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138496,
          -34.88618
        ],
        [
          -56.13906,
          -34.88576
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138596,
          -34.885933
        ],
        [
          -56.13895,
          -34.885666
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138107,
          -34.886303
        ],
        [
          -56.138596,
          -34.885933
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.14018,
          -34.886513
        ],
        [
          -56.140312,
          -34.88631
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.1386,
          -34.888718
        ],
        [
          -56.138165,
          -34.88937
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13726,
          -34.888638
        ],
        [
          -56.137054,
          -34.888943
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13748,
          -34.88831
        ],
        [
          -56.13726,
          -34.888638
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138706,
          -34.888767
        ],
        [
          -56.138226,
          -34.88947
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138313,
          -34.887074
        ],
        [
          -56.138515,
          -34.886765
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13925,
          -34.88757
        ],
        [
          -56.138264,
          -34.887188
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138165,
          -34.887356
        ],
        [
          -56.1375,
          -34.887096
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.137287,
          -34.886932
        ],
        [
          -56.13686,
          -34.887264
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138264,
          -34.887188
        ],
        [
          -56.137672,
          -34.886963
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.139153,
          -34.887745
        ],
        [
          -56.138165,
          -34.887356
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138607,
          -34.88847
        ],
        [
          -56.137623,
          -34.888096
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.136467,
          -34.887573
        ],
        [
          -56.136684,
          -34.887737
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13686,
          -34.887264
        ],
        [
          -56.136467,
          -34.887573
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.136837,
          -34.88646
        ],
        [
          -56.135834,
          -34.88649
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13782,
          -34.88643
        ],
        [
          -56.136837,
          -34.88646
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.137577,
          -34.888195
        ],
        [
          -56.13658,
          -34.887817
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138573,
          -34.888577
        ],
        [
          -56.137577,
          -34.888195
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138046,
          -34.88747
        ],
        [
          -56.137802,
          -34.88783
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.137802,
          -34.88783
        ],
        [
          -56.137623,
          -34.888096
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.137623,
          -34.888096
        ],
        [
          -56.136684,
          -34.887737
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13919,
          -34.886795
        ],
        [
          -56.138515,
          -34.886765
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138515,
          -34.886765
        ],
        [
          -56.13796,
          -34.886738
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.139996,
          -34.88683
        ],
        [
          -56.139877,
          -34.886826
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.139877,
          -34.886826
        ],
        [
          -56.13919,
          -34.886795
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.139404,
          -34.887524
        ],
        [
          -56.139877,
          -34.886826
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13952,
          -34.88756
        ],
        [
          -56.139996,
          -34.88683
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.138153,
          -34.886555
        ],
        [
          -56.13796,
          -34.886738
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.13796,
          -34.886738
        ],
        [
          -56.137672,
          -34.886963
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.1375,
          -34.887096
        ],
        [
          -56.136684,
          -34.887737
        ]
      ]
    ]
  },
  {
    "type": "MultiLineString",
    "coordinates": [
      [
        [
          -56.139156,
          -34.8866
        ],
        [
          -56.138153,
          -34.886555
        ]
      ]
    ]
  }
];

class MapComponent extends StatefulWidget {
  @override
  _MapComponentState createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  Position? location;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          errorMsg = 'Permission to access location was denied';
        });
        return;
      }

      Position currentPosition = await Geolocator.getCurrentPosition();
      setState(() {
        location = currentPosition;
      });
    } catch (e) {
      setState(() {
        errorMsg = 'Error fetching location';
      });
    }
  }

  Set<Polyline> getPolylines() {
    return mockLines.map((line) {
      List<List<double>> coordinates = List<List<double>>.from(line['coordinates'][0]);
      List<LatLng> latLngList = coordinates
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList();
      return Polyline(
        polylineId: PolylineId(line.hashCode.toString()),
        points: latLngList,
        color: Colors.red,
        width: 5,
        onTap: () => handlePolylinePress(line['id']),
      );
    }).toSet();
  }

  void handlePolylinePress(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Línea clickeada'),
        content: Text('Línea con ID: $id fue clickeada'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-34.88773, -56.13955),
          zoom: 15,
        ),
        polylines: getPolylines(),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
