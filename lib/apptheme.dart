import 'package:flutter/material.dart';

extension AddPadding on Widget {
  Widget p(double pad) => Padding(padding: EdgeInsets.all(pad), child: this);
  Widget pl(double pad) => Padding(padding: EdgeInsets.only(left: pad), child: this);
  Widget pt(double pad) => Padding(padding: EdgeInsets.only(top: pad), child: this);
  Widget pr(double pad) => Padding(padding: EdgeInsets.only(right: pad), child: this);
  Widget pb(double pad) => Padding(padding: EdgeInsets.only(bottom: pad), child: this);
  Widget pLTRB(double padL, double padT, double padR, double padB) => Padding(padding: EdgeInsets.fromLTRB(padL, padT, padR, padB), child: this);
}

extension AddExpanded on Widget {
  Widget exp([flex = 1]) => Expanded(flex: flex, child: this);
}