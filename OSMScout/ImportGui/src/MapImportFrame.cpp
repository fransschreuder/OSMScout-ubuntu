/***************************************************************
 * Name:      OsmscoutImportGuiMain.cpp
 * Purpose:   Code for Application Frame
 * Author:    Frans Schreuder (info@schreuderelectronics.com)
 * Created:   2015-05-29
 * Copyright: Frans Schreuder (www.schreuderelectronics.com)
 * License:
 **************************************************************/


#include "MapImportFrame.h"
#include <wx/process.h>
#include <wx/txtstrm.h>






MapImportFrame::MapImportFrame(wxFrame *frame)
    : MapImportFrameBase(frame)
{
    timer = new wxTimer(this);
	this->Connect( timer->GetId(), wxEVT_TIMER, wxTimerEventHandler( MapImportFrame::onTimer ) );
}

MapImportFrame::~MapImportFrame()
{
}

void MapImportFrame::OnClose(wxCloseEvent &event)
{
    Destroy();
}

void MapImportFrame::OnQuit(wxCommandEvent &event)
{
    Destroy();
}

void MapImportFrame::onStart( wxCommandEvent& event )
{
 Execute("osmscout-import "+m_filePickerSrc->GetPath());
}

void MapImportFrame::Execute(const wxString& command)
{


   process = new wxProcess(wxPROCESS_REDIRECT);
   pid = wxExecute(command, wxEXEC_ASYNC, process);
   process->Redirect();

   if (process)
   {

      msg = process->GetInputStream();

      tStream = new wxTextInputStream(*msg);
      timer->Start(1,true); //start one shot


   } else {
      m_Console->AppendText(wxT("FAIL: Command" + command + " could not be run!\n"));
   }
}


void MapImportFrame::onTimer(wxTimerEvent& event)
{
  wxString log;
  if(wxProcess::Exists(pid))
  {
     log = tStream->ReadLine();
     m_Console->AppendText(log+wxT("\n"));
     timer->StartOnce(5);
  }
  else
  {
    m_Console->AppendText(wxT("Finished!\n"));
  }
}
