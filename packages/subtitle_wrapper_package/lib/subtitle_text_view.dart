import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subtitle_wrapper_package/bloc/subtitle/subtitle_bloc.dart';
import 'package:subtitle_wrapper_package/data/constants/view_keys.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';

class SubtitleTextView extends StatelessWidget {
  const SubtitleTextView({
    required this.subtitleStyle,
    super.key,
    this.backgroundColor,
  });
  final SubtitleStyle subtitleStyle;
  final Color? backgroundColor;

  TextStyle get _textStyle {
    return subtitleStyle.hasBorder
        ? TextStyle(
            fontSize: subtitleStyle.fontSize,
            foreground: Paint()
              ..style = subtitleStyle.borderStyle.style
              ..strokeWidth = subtitleStyle.borderStyle.strokeWidth
              ..color = subtitleStyle.borderStyle.color,
          )
        : TextStyle(
            fontSize: subtitleStyle.fontSize,
            color: subtitleStyle.textColor,
          );
  }

  @override
  Widget build(BuildContext context) {
    final subtitleBloc = BlocProvider.of<SubtitleBloc>(context);

    // TODO(Joran-Dob): improve this workaround.
    void subtitleBlocListener(BuildContext _, SubtitleState state) {
      if (state is SubtitleInitialized) {
        subtitleBloc.add(LoadSubtitle());
      }
    }

    return BlocConsumer<SubtitleBloc, SubtitleState>(
      listener: subtitleBlocListener,
      builder: (context, state) {
        if (state is LoadedSubtitle && state.subtitle != null) {
          return Stack(
            children: <Widget>[
              Center(
                child: Container(
                  color: backgroundColor,
                  child: _TextContent(
                    text: state.subtitle!.text,
                    textStyle: _textStyle,
                  ),
                ),
              ),
              if (subtitleStyle.hasBorder)
                Center(
                  child: Container(
                    color: backgroundColor,
                    child: _TextContent(
                      text: state.subtitle!.text,
                      textStyle: TextStyle(
                        color: subtitleStyle.textColor,
                        fontSize: subtitleStyle.fontSize,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _TextContent extends StatelessWidget {
  const _TextContent({
    required this.textStyle,
    required this.text,
  });

  final TextStyle textStyle;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      key: ViewKeys.subtitleTextContent,
      textAlign: TextAlign.center,
      style: textStyle,
    );
  }
}
