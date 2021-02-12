# ARKitCube
Demo app to render a cube with ARKit and SceneKit, from this [reddit thread](https://www.reddit.com/r/iOSProgramming/comments/lguoe9/anybody_would_be_interested_on_helping_a_blind/?utm_source=share&utm_medium=web2x&context=3). Each face of the cube is a different color, and a different note is played when they are tapped. All code is in [ViewController.swift](https://github.com/aheze/ARKitCube/blob/main/ARKitCube/ViewController.swift).

**Update:** Now, the cube also repeatedly emits a sound, [1Mono.mp3](https://drive.google.com/uc?export=view&id=1bJzocuIN-K95y7eJNd1hPNBFWbRgbuxh). This uses positional audio, so when you get closer, the sound is louder. And when you get further away, it gets softer.

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

