
import 'package:flutter/material.dart';
import 'package:my_mikhailovka/app_localizations.dart';
import 'package:my_mikhailovka/domain/mikhailovka/mikhailovka_manager.dart';
import 'package:my_mikhailovka/domain/transport_manager.dart';
import 'package:my_mikhailovka/resources.dart';

typedef void ForecastTabChanged(int tabIndex);
typedef void ForecastClicked(StationForecast forecast);

class Forecasts extends StatefulWidget {
  Forecasts({this.mikhailovkaManager, this.currentTabChanged, this.forecastClicked, this.scrollController});

  final MikhailovkaManager mikhailovkaManager;
  final ForecastTabChanged currentTabChanged;
  final ForecastClicked forecastClicked;
  final ScrollController scrollController;

  @override
  State<StatefulWidget> createState() => _ForecastsState();
}

class _ForecastsState extends State<Forecasts> {

  MikhailovkaManager get mikhailovkaManager => widget.mikhailovkaManager;
  var _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0))
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTabs(),
            Flexible(
              fit: FlexFit.tight,
              child: _currentTab == 0
                  ? _buildPage(mikhailovkaManager.observePivzavodStationForecasts())
                  : _buildPage(mikhailovkaManager.observeLeninaStationForecasts())
            ),
          ],
        )
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Expanded(child: _buildTab(AppLocalizations.of(context).homeDirectionFrom, 0)
        ),
        Expanded(child: _buildTab(AppLocalizations.of(context).homeDirectionTo, 1)),
      ],
    );
  }

  Widget _buildTab(String text, int index) {
    var selected = _currentTab == index;

    return InkWell(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
              height: 56.0,
              width: double.infinity
          ),
          AnimatedOpacity(
            opacity: selected ? 1.0 : 0.3,
            duration: Duration(milliseconds: 300),
            child: Text(text, style: Theme.of(context).textTheme.button,),
          ),
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: selected ? 1.0 : 0.0,
              duration: Duration(milliseconds: 100),
              child: Container(
                height: 4.0,
                color: Colors.blueAccent,
                margin: EdgeInsets.symmetric(horizontal: 24.0),
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        setState(() {
          _currentTab = index;
        });
        widget.currentTabChanged(index);
      },
    );
  }

  Widget _buildPage(Stream<List<StationForecast>> stream) {
    return StreamBuilder(
        stream: stream,
        builder: (context, AsyncSnapshot<List<StationForecast>> snapshot) {
          List<Widget> children = [];

          if(snapshot.hasError) {
            print(snapshot.error.toString());
            children.add(Container(
              margin: EdgeInsets.all(16.0),
              child: Text("Ошибка!", key: UniqueKey(), textAlign: TextAlign.center,),
            ));
          } else if(!snapshot.hasData) {
            children.add(Container(
              margin: EdgeInsets.all(16.0),
              child: Text("Загрузка...", key: UniqueKey(), textAlign: TextAlign.center,),
            ));
          } else if(snapshot.data.isEmpty) {
            children.add(Container(
              margin: EdgeInsets.all(16.0),
              child: Text("Пусто", key: UniqueKey(), style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
            ));
          } else {
            var forecasts = snapshot.data;
            children.addAll(
              forecasts.map((forecast) {
                return _buildForecastItem(forecast);
              }).toList(),
            );
          }

          return Scrollbar(
            key: ObjectKey(snapshot.data),
            child: ListView.builder(
              controller: widget.scrollController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: children.length,
              itemBuilder: (context, index) {
                return children[index];
              },
            ),
          );
        }
    );
  }

  Widget _buildForecastItem(StationForecast forecast) {
    var minutes = forecast.tillArrival.inMinutes;
    var seconds = forecast.tillArrival.inSeconds - (minutes * 60);

    return InkWell(
      onTap: () {
        widget.forecastClicked(forecast);
      },
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: Resources.routeTypeColor(forecast.routeType)
            ),
            child: Text(
              forecast.routeName,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16.0),
              child: Text(
                "$minutes мин $seconds сек",
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.subhead,
              ),
            ),
          ),
        ],
      ),
    );
  }

}