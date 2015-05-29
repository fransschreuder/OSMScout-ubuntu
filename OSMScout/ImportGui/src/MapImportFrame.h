/***************************************************************
 * Name:      OsmscoutImportGuiMain.h
 * Purpose:   Defines Application Frame
 * Author:    Frans Schreuder (info@schreuderelectronics.com)
 * Created:   2015-05-29
 * Copyright: Frans Schreuder (www.schreuderelectronics.com)
 * License:
 **************************************************************/

#ifndef OSMSCOUTIMPORTGUIMAIN_H
#define OSMSCOUTIMPORTGUIMAIN_H

#include <wx/wx.h>
#include <wx/process.h>
#include <wx/txtstrm.h>

#include "MapImportFrame.h"


#include "MapImportFrameBase.h"

class MapImportFrame: public MapImportFrameBase
{
    public:
        MapImportFrame(wxFrame *frame);
        ~MapImportFrame();
    private:
        virtual void OnClose(wxCloseEvent& event);
        virtual void OnQuit(wxCommandEvent& event);
        virtual void onStart( wxCommandEvent& event );
        void Execute(const wxString& command);
        void onTimer(wxTimerEvent& event);

        wxInputStream *msg;
        wxTextInputStream *tStream;
        wxTimer* timer;
        wxProcess *process;
        long pid;
};

#endif // OSMSCOUTIMPORTGUIMAIN_H
