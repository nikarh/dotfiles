package main

import (
	"flag"
	"fmt"
	"github.com/auroralaboratories/pulse"
	"math"
	"github.com/godbus/dbus"
	"github.com/esiqveland/notify"
	"log"
	"github.com/alexflint/go-filemutex"
)

func getAudioLevelIconName(volume float64) string {
	switch {
	case volume == 0:
		return "audio-volume-muted"
	case volume < 35:
		return "audio-volume-low"
	case volume < 70:
		return "audio-volume-medium"
	default:
		return "audio-volume-high"
	}
}

func doNotify(summary, body string, icon string, id int) {
	conn, err := dbus.SessionBus()
	if err != nil {
		panic(err)
	}

	n := notify.Notification{
		AppName:       "control.sh",
		AppIcon:       icon,
		ReplacesID:    uint32(id),
		Summary:       summary,
		Body:          body,
		ExpireTimeout: int32(5000),
	}

	_, err = notify.SendNotification(conn, n)
	if err != nil {
		log.Printf("error sending notification: %v", err.Error())
	}
}

func waitLock(name string) func() error {
	m, err := filemutex.New(fmt.Sprintf("/tmp/%s.lock", name))
	if err != nil {
		log.Fatalf("could not create lock file: %s", err)
	}

	m.Lock()
	return m.Unlock
}

func volumeInc() {
	pa, err := pulse.NewClient("control")
	if err != nil {
		fmt.Errorf("could not create pa client: %e", err)
	}

	sinks, err := pa.GetSinks()
	if err != nil {
		fmt.Errorf("could not get pa sinks: %e", err)
	}

	for _, s := range sinks {
		s.SetVolume(math.Min(s.VolumeFactor+0.05, 1))

		if err != nil {
			fmt.Errorf("could not set volume: %e", err)
		}

		doNotify("",
			fmt.Sprintf("Voume set to %.f%%", s.VolumeFactor*100),
			getAudioLevelIconName(s.VolumeFactor * 100),
			1)
	}

}

func volumeDec() {
	pa, err := pulse.NewClient("control")
	if err != nil {
		fmt.Errorf("could not create pa client: %e", err)
	}

	sinks, err := pa.GetSinks()
	if err != nil {
		fmt.Errorf("could not get pa sinks: %e", err)
	}

	for _, s := range sinks {
		err := s.DecreaseVolume(0.05)
		if err != nil {
			fmt.Errorf("could not decrease volume: %e", err)
		}

		doNotify("",
			fmt.Sprintf("Voume set to %.f%%", s.VolumeFactor*100),
			getAudioLevelIconName(s.VolumeFactor * 100),
			1)
	}
}

func volumeToggle() {
	pa, err := pulse.NewClient("control")
	if err != nil {
		fmt.Errorf("could not create pa client: %e", err)
	}

	sinks, err := pa.GetSinks()
	if err != nil {
		fmt.Errorf("could not get pa sinks: %e", err)
	}

	for _, s := range sinks {
		s.ToggleMute()
		if err != nil {
			fmt.Errorf("could not toggle mute: %e", err)
		}

		if s.Muted {
			doNotify("",
				fmt.Sprintf("Audio device muted"),
				getAudioLevelIconName(0),
				1)
		} else {
			doNotify("",
				fmt.Sprintf("Audio device unmuted"),
				getAudioLevelIconName(s.VolumeFactor * 100),
				1)
		}
	}
}

func main() {
	flag.Parse()
	cmd, subcmd := flag.Arg(0), flag.Arg(1)

	switch cmd {
	case "volume":
		switch subcmd {
		case "inc":
			volumeInc()
		case "dec":
			volumeDec()
		case "toggle":
			volumeToggle()
		default:
			fmt.Printf("unknown subcommand '%s'", subcmd)
		}
	default:
		fmt.Printf("unknown command '%s'", cmd)
	}
}
