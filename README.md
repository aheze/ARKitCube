# ARKitCube
Demo app to render a cube with ARKit and SceneKit, from this [reddit thread](https://www.reddit.com/r/iOSProgramming/comments/lguoe9/anybody_would_be_interested_on_helping_a_blind/?utm_source=share&utm_medium=web2x&context=3). Each face of the cube is a different color, and a different note is played when they are tapped.

## I've ported this project over to SwiftUI. The UIKit code is still available, in [Legacy-UIKit/](https://github.com/aheze/ARKitCube/tree/main/Legacy-UIKit).

The main code is in [ContentView/swift](https://github.com/aheze/ARKitCube/blob/main/ARKitCube-SwiftUI/ARKitCube-SwiftUI/ContentView.swift).
The code for porting the ARKit Scene View over to SwiftUI is in [ARSCNView.swift](https://github.com/aheze/ARKitCube/blob/main/ARKitCube-SwiftUI/ARKitCube-SwiftUI/ARSCNView.swift).

Features:
- The cube repeatedly emits a sound, [1Mono.mp3](https://drive.google.com/uc?export=view&id=1bJzocuIN-K95y7eJNd1hPNBFWbRgbuxh). This uses spatial/positional audio, so when you get closer, the sound is louder. And when you get further away, it gets softer.
- VoiceOver compatibility - make sure to turn on Direct Touch Mode using the Rotor.
- Left button - performs hit testing at the exact center point of the screen.
- Right button - tells you how far away the cube is, in angles (degrees).

[![Video of the app](https://github.com/aheze/DeveloperAssets/blob/master/PlayArCube.png?raw=true)](https://drive.google.com/file/d/1YVZ8GmiXHFXEx-aGx4h4gKprpPeCjvaS/view?usp=sharing)

Here is a table showing which note will be played for each face that is pressed:

Face number | Color | Note
--- | --- | ---
0 (front) | red | [1Do.mp3](https://drive.google.com/uc?export=view&id=1lKvyJr7OGgDOJqcSYz7DsFPnKSzeFNrf)
1 (right) | orange | [2Re.mp3](https://drive.google.com/uc?export=view&id=1Usa1h_6Ft0CQxksCBqPY3os8HSDv3gKG)
2 (back) | yellow | [3Mi.mp3](https://drive.google.com/uc?export=view&id=1gANm3fix4zACNej28pIUqOfCwHzLFj-P)
3 (left) | green | [4Fa.mp3](https://drive.google.com/uc?export=view&id=19n84EpfaEilxXpOuSQlS3RyskcnTYiZl)
4 (top) | blue | [5So.mp3](https://drive.google.com/uc?export=view&id=1QIJABrbopVd0GNRxaQTLAAMi1HN8rvHQ)
5 (bottom) | purple | [6La.mp3](https://drive.google.com/uc?export=view&id=178iFmo8R3JYfr6tHoRNQJsuiIs5XgL-c)

