import 'package:flutter/material.dart';
class AccessibilityPanel extends StatelessWidget {
  const AccessibilityPanel({super.key,required this.textScale,required this.highContrast,required this.reducedMotion,required this.onTextScale,required this.onHighContrast,required this.onReducedMotion});
  final double textScale; final bool highContrast; final bool reducedMotion; final ValueChanged<double> onTextScale; final ValueChanged<bool> onHighContrast; final ValueChanged<bool> onReducedMotion;
  @override Widget build(BuildContext context)=>Semantics(label:'Accessibility settings',container:true,child:ListView(shrinkWrap:true,children:[
    const ListTile(title:Text('Accessibility'),subtitle:Text('Adjust how the application is displayed and animated.')),
    ListTile(title:const Text('Text size'),subtitle:Slider(value:textScale,min:0.9,max:1.6,divisions:7,label:textScale.toStringAsFixed(1),onChanged:onTextScale)),
    SwitchListTile(title:const Text('High contrast'),value:highContrast,onChanged:onHighContrast),
    SwitchListTile(title:const Text('Reduce motion'),value:reducedMotion,onChanged:onReducedMotion),
  ]));
}
